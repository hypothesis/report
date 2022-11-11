import csv
import json
import os.path
from dataclasses import dataclass
from enum import Enum
from typing import Callable, Generator, Iterable, List, Optional

from hubspot import HubSpot
from hubspot.crm.associations import BatchInputPublicObjectId


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

    def get_companies(self, fields: Iterable[Field]) -> Generator:
        """Get companies from Hubspot.

        :param fields: A list of fields to get from Hubspot
        """

        yield from self._get_objects(self.api_client.crm.companies, fields)

    def get_deals(self, fields: Iterable[Field]) -> Generator:
        """Get deals from Hubspot.

        :param fields: A list of fields to get from Hubspot
        """

        yield from self._get_objects(self.api_client.crm.deals, fields)

    def get_associations(
        self,
        from_type: AssociationObjectType,
        to_type: AssociationObjectType,
        object_ids: List,
    ) -> Generator:
        """Get inter object relationships.

        :param from_type: Object on the left hand side of the relationship
        :param to_type: Object on the right hand side of the relationship
        :param object_ids: Object ids of the left hand side objects
        """
        results = self.api_client.crm.associations.batch_api.read(
            from_object_type=from_type.value,
            to_object_type=to_type.value,
            batch_input_public_object_id=BatchInputPublicObjectId(
                inputs=[str(object_id) for object_id in object_ids]
            ),
        )

        for result in results.results:
            for to_result in result.to:
                # pylint: disable=protected-access
                # This just appears to be part of the goofy interface
                yield result._from.id, to_result.id

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
    def _csv_import_request(cls, job_name, csv_files, object_type, primary_key_field):
        # We're pretty much always going to have one CSV file here, but the API
        # requires an array, and we might as well cope with it elegantly. It's
        # actually a nice feature for us, as a Spark partitioned DataFrame will
        # write out a separate CSV file for each partition.

        files = [
            {
                "fileName": os.path.basename(csv_file),
                "fileFormat": "CSV",
                # We don't have any dates, but if we do, use ISO ordering
                "dateFormat": "YEAR_MONTH_DAY",
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

        return {"name": job_name, "files": files}

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
    def _get_objects(cls, accessor, fields):
        for item in accessor.get_all(properties=[field.hs_field for field in fields]):
            # Filter and map the requested fields
            result = {}
            for field in fields:
                value = item.properties[field.hs_field] or None
                if value and field.mapping:
                    value = field.mapping(value)

                result[field.key] = value

            yield result
