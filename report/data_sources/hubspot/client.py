import csv
import json
import os.path
import time
from dataclasses import dataclass
from enum import Enum
from http import HTTPStatus
from typing import Callable, Generator, Iterable, List, Optional, Set

from hubspot import HubSpot
from hubspot.crm.associations import BatchInputPublicObjectId
from hubspot.crm.contacts import Filter, FilterGroup, PublicObjectSearchRequest
from hubspot.crm.objects.exceptions import ApiException

from report.data_sources.chunk import chunk, chunk_with_max_len

RATE_LIMIT_SECONDS = 5


@dataclass
class Field:
    """Define a mapping from a remote field to a chosen key."""

    hs_field: str
    key: str = None
    mapping: Optional[Callable] = None

    def __post_init__(self):
        if not self.key:
            self.key = self.hs_field


@dataclass
class HubspotClient:
    """A nicer client for the Hubspot API."""

    private_app_key: str
    api_client: HubSpot = None

    # From: https://developers.hubspot.com/docs/api/crm/imports
    class ObjectType:  # pylint: disable=too-few-public-methods
        """Hubspot codes for different entity types."""

        CONTACT = "0-1"
        COMPANY = "0-2"
        DEAL = "0-3"
        NOTES = "0-4"
        TICKET = "0-5"

    # From: https://developers.hubspot.com/docs/api/crm/associations/v3
    class AssociationObjectType(Enum):
        CONTACT = "Contacts"
        COMPANY = "Companies"
        DEAL = "Deals"
        TICKET = "Tickets"
        # There are more, but I don't think we'll ever use them

    class IDType:  # pylint: disable=too-few-public-methods
        """Hubspot codes for different field types."""

        PRIMARY_KEY = "HUBSPOT_OBJECT_ID"
        REGULAR_FIELD = None

    def __post_init__(self):
        self.api_client = HubSpot()
        self.api_client.access_token = self.private_app_key

    ASSOCIATIONS_BATCH_SIZE = 11000

    def get_associations(
        self,
        from_type: AssociationObjectType,
        to_type: AssociationObjectType,
        object_ids: List,
    ) -> Set:
        """Get inter object relationships.

        :param from_type: Object on the left hand side of the relationship
        :param to_type: Object on the right hand side of the relationship
        :param object_ids: Object ids of the left hand side objects
        """

        # For reasons unclear, we appear to get duplicate entries in the return
        # values, so we'll use a set to dedupe them
        relations = set()

        # 11k is the maximum we can ask for at once from Hubspot
        for id_chunk in chunk(object_ids, chunk_size=self.ASSOCIATIONS_BATCH_SIZE):
            results = self.api_client.crm.associations.batch_api.read(
                from_object_type=from_type.value,
                to_object_type=to_type.value,
                batch_input_public_object_id=BatchInputPublicObjectId(
                    # Dedupe ids in-case we are provided the same one twice
                    inputs=list(set(str(object_id) for object_id in id_chunk))
                ),
            )

            for result in results.results:
                for to_result in result.to:
                    # pylint: disable=protected-access
                    # This just appears to be part of the goofy interface
                    relations.add((result._from.id, to_result.id))

        return relations

    def get_companies(self, fields: Iterable[Field]) -> Generator:
        """Get companies from Hubspot.

        :param fields: A list of fields to get from Hubspot
        """

        yield from self._get_objects(self.api_client.crm.companies, fields)

    def get_contacts(self, fields: Iterable[Field]) -> Generator:
        """Get contacts from Hubspot.

        :param fields: A list of fields to get from Hubspot
        """

        yield from self._get_objects(self.api_client.crm.contacts, fields)

    def get_contacts_by_email(self, emails, fields: Iterable[Field]):
        # We can't have more than 100 items in an IN query, we also can't have
        # more than 3000 chars in our total request.
        for email_batch in chunk_with_max_len(emails, chunk_size=100, max_chars=2000):
            yield from self._get_contacts_by_email(
                email_batch=email_batch, fields=fields, limit=100
            )

    def _get_contacts_by_email(
        self, email_batch, fields: Iterable[Field], limit, max_retries=5
    ):
        # Pick the largest size we are allowed
        limit = max(limit, 100)

        # Example of searching here:
        # https://github.com/HubSpot/sample-apps-search-results-iterating/blob/main/python/cli.py
        # That demonstrates pagination, which we are hoping we can get away
        # without because we ask for 100 emails max.

        filter_ = Filter(property_name="email", operator="IN", values=list(email_batch))
        request = PublicObjectSearchRequest(
            limit=limit,
            properties=[field.hs_field for field in fields],
            filter_groups=[FilterGroup(filters=[filter_])],
        )

        # Example of the retry mechanism here:
        # https://github.com/HubSpot/sample-apps-rate-limit/blob/master/python/cli.py
        # Which has been updated to not end-up with unassigned response object
        retries = 0
        while True:
            try:
                response = self.api_client.crm.contacts.search_api.do_search(request)
                break
            except ApiException as err:
                if (
                    retries < max_retries
                ) and err.status == HTTPStatus.TOO_MANY_REQUESTS:
                    print(
                        f"Rate limit exceeded, retrying in {RATE_LIMIT_SECONDS} seconds..."
                    )
                    time.sleep(RATE_LIMIT_SECONDS)
                    retries += 1
                else:
                    raise  # Reraise the exception if it's not a rate limit error

        if len(response.results) == limit:
            print("Potential pagination error! We got the same size as our batch size")

        return [self._map_item(item, fields) for item in response.results]

    def get_deals(self, fields: Iterable[Field]) -> Generator:
        """Get deals from Hubspot.

        :param fields: A list of fields to get from Hubspot
        """

        yield from self._get_objects(self.api_client.crm.deals, fields)

    def get_owners(self):
        """Get a list of the owners."""

        return (owner.to_dict() for owner in self.api_client.crm.owners.get_all())

    def get_properties(self, object_type):
        """
        Get the properties for a given object type.

        This is useful for trying to work out what a property you want is
        called by Hubspot internally.
        """

        return (
            prop.to_dict()
            for prop in self.api_client.crm.properties.core_api.get_all(
                object_type
            ).results
        )

    def import_csv(
        self, job_name, csv_files, object_type, primary_key_field="hs_object_id"
    ):
        """Start an import data from a CSV file to Hubspot to update objects.

        The CSV file should have one row per objects with a header row and will
        start an asynchronous import. The process of actually importing the
        data will happen when Hubspot gets round to it.

        :param job_name: Arbitrary name displayed in the Hubspot import page
        :param csv_files: A list of files to upload
        :param object_type: The type of object to load
        :param primary_key_field: Which field contains the object primary id

        :raises FileNotFoundError: If any of the provided CSV files are missing
        :return: The result of the upload
        """

        # Let's do a few sanity checks
        for csv_file in csv_files:
            if not os.path.isfile(csv_file):
                raise FileNotFoundError(f"Cannot find CSV file: '{csv_file}'")

        import_request = self._csv_import_request(
            job_name=job_name,
            csv_files=csv_files,
            object_type=object_type,
            primary_key_field=primary_key_field,
        )

        return self.api_client.crm.imports.core_api.create(
            import_request=json.dumps(import_request),
            files=csv_files,
            async_req=False,
        )

    @classmethod
    def parse_teams_from_owners(cls, owners):
        """Parse owner team relations and teams from owners."""

        teams_by_id = {}
        owner_team = []

        for owner in owners:
            if not owner["teams"]:
                continue

            for team in owner["teams"]:
                teams_by_id[team["id"]] = team
                owner_team.append(
                    {"owner_id": int(owner["id"]), "team_id": int(team["id"])}
                )

        # Sort and convert ids to ints
        teams = list(teams_by_id.values())
        for team in teams:
            team["id"] = int(team["id"])

        return owner_team, teams

    @classmethod
    def _csv_import_request(cls, job_name, csv_files, object_type, primary_key_field):
        # We're pretty much always going to have one CSV file here, but the API
        # requires an array, and we might as well cope with it elegantly. It's
        # actually a nice feature for us, as a Spark partitioned DataFrame will
        # write out a separate CSV file for each partition.

        files = [
            {
                "fileName": os.path.basename(csv_file),
                "fileFormat": "CSV",
                "fileImportPage": {
                    "hasHeader": True,
                    # All the column mappings should be the same, but just in
                    # case we get more than one file, and in case they have
                    # different orders, we'll do them separately.
                    "columnMappings": list(
                        cls._column_mapping_from_csv(
                            csv_file=csv_file,
                            object_type=object_type,
                            primary_key_field=primary_key_field,
                        )
                    ),
                },
            }
            for csv_file in csv_files
        ]

        return {
            "name": job_name,
            "files": files,
            # We don't have any dates, but if we do, use ISO ordering
            "dateFormat": "YEAR_MONTH_DAY",
        }

    @classmethod
    def _column_mapping_from_csv(cls, csv_file, object_type, primary_key_field):
        # We need to provide a column mapping for Hubspot, but it ignores the
        # column names and just relies on order. This makes it very easy to
        # supply the right columns in the wrong order, so we'll just read them
        # from the CSV header instead.
        primary_found = False

        with open(csv_file, encoding="utf-8") as handle:
            try:
                header = next(csv.reader(handle))
            except StopIteration as err:
                raise EOFError("Could not read header from CSV file") from err

        for column_name in header:
            if column_name == primary_key_field:
                yield {
                    "columnObjectTypeId": object_type,
                    "columnName": column_name,
                    "propertyName": "hs_object_id",
                    "idColumnType": cls.IDType.PRIMARY_KEY,
                }
                primary_found = True
            else:
                yield {
                    "columnObjectTypeId": object_type,
                    "columnName": column_name,
                    "propertyName": column_name,
                    "idColumnType": cls.IDType.REGULAR_FIELD,
                }

        if not primary_found:
            raise KeyError(
                f"Could not find primary key column: {primary_key_field} in CSV file {csv_file}"
            )

    @classmethod
    def _get_objects(cls, accessor, fields: Iterable[Field]):
        for item in accessor.get_all(properties=[field.hs_field for field in fields]):
            yield cls._map_item(item, fields)

    @classmethod
    def _map_item(cls, item, fields: Iterable[Field]):
        result = {}
        for field in fields:
            value = item.properties[field.hs_field] or None
            if value and field.mapping:
                value = field.mapping(value)

            result[field.key] = value

        return result
