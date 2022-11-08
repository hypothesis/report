import csv
import json
import os.path
from dataclasses import dataclass
from typing import List

from hubspot import HubSpot


@dataclass
class HubspotClient:
    """A nicer client for the Hubspot API."""

    private_app_key: str
    api_client: HubSpot = None

    class ObjectType:  # pylint: disable=too-few-public-methods
        """Hubspot codes for different entity types."""

        COMPANY = "0-2"

    class IDType:  # pylint: disable=too-few-public-methods
        """Hubspot codes for different field types."""

        PRIMARY_KEY = "HUBSPOT_OBJECT_ID"
        REGULAR_FIELD = None

    def __post_init__(self):
        self.api_client = HubSpot()
        self.api_client.access_token = self.private_app_key

    def get_companies(self, properties):
        """Get companies from Hubspot.

        :param properties: A list of properties to get from Hubspot
        :return: A generator of dicts
        """

        for company in self.api_client.crm.companies.get_all(properties=properties):
            # Hubspot gives us a bunch of fields we don't ask for, so filter
            # back to the requested fields
            yield {key: company.properties[key] for key in properties}

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


@dataclass
class DummyHubspotClient:
    """A fake Hubspot Client which can be used in tests."""

    companies: List[dict] = None

    def get_companies(self, *args, **kwargs):
        """Replicates the method from the real object."""

        print("DummyHubspotClient: get_companies() called with", args, kwargs)
        return self.companies

    @classmethod
    def import_csv(cls, *args, **kwargs):
        """Replicates the method from the real object."""

        print("DummyHubspotClient: import_csv() called with", args, kwargs)
