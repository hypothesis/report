import json
from dataclasses import dataclass

import pytest
from pytest import fixture

from report.data_sources.hubspot_client import DummyHubspotClient, HubspotClient


@dataclass
class FakeCompany:
    properties: dict


class TestHubspotClient:
    def test___post_init__(self, client, HubSpot):
        HubSpot.assert_called_once_with()
        assert client.api_client == HubSpot.return_value
        assert client.api_client.access_token == "api_key"

    def test_get_companies(self, client):
        client.api_client.crm.companies.get_all.return_value = [
            FakeCompany({"wanted": "value", "unwanted": "bad_value"})
        ]

        results = client.get_companies(properties=["wanted"])

        assert list(results) == [{"wanted": "value"}]

    def test_import_csv_raises_for_missing_files(self, client):
        with pytest.raises(FileNotFoundError):
            client.import_csv("job_name", ["/not/a/real/file.csv"], "object_type")

    def test_import_csv_raises_for_missing_primary_column(self, client, csv_file):
        with pytest.raises(KeyError):
            client.import_csv(
                "job_name",
                [csv_file],
                "object_type",
                primary_key_field="NOT_A_PRIMARY_FIELD",
            )

    def test_import_csv_raises_for_empty_files(self, client, tmp_path):
        csv_file = tmp_path / "file.csv"
        csv_file.write_text("")

        with pytest.raises(EOFError):
            client.import_csv(
                "job_name", [csv_file], "object_type", primary_key_field="key"
            )

    def test_import_csv(self, client, csv_file):
        result = client.import_csv(
            "job_name", [csv_file], "object_type", primary_key_field="primary_key"
        )

        create = client.api_client.crm.imports.core_api.create
        create.assert_called_once_with(
            import_request=json.dumps(
                {
                    "name": "job_name",
                    "files": [
                        {
                            "fileName": "file.csv",
                            "fileFormat": "CSV",
                            "dateFormat": "YEAR_MONTH_DAY",
                            "fileImportPage": {
                                "hasHeader": True,
                                "columnMappings": [
                                    {
                                        "columnObjectTypeId": "object_type",
                                        "columnName": "primary_key",
                                        "propertyName": "hs_object_id",
                                        "idColumnType": HubspotClient.IDType.PRIMARY_KEY,
                                    },
                                    {
                                        "columnObjectTypeId": "object_type",
                                        "columnName": "heading_1",
                                        "propertyName": "heading_1",
                                        "idColumnType": HubspotClient.IDType.REGULAR_FIELD,
                                    },
                                    {
                                        "columnObjectTypeId": "object_type",
                                        "columnName": "heading_2",
                                        "propertyName": "heading_2",
                                        "idColumnType": HubspotClient.IDType.REGULAR_FIELD,
                                    },
                                ],
                            },
                        }
                    ],
                }
            ),
            files=[csv_file],
            async_req=False,
        )

        assert result == create.return_value

    @fixture
    def csv_file(self, tmp_path):
        csv_file = tmp_path / "file.csv"
        csv_file.write_text("primary_key,heading_1,heading_2\n1,value_1,value_2")

        return str(csv_file)

    @fixture
    def client(self):
        return HubspotClient(private_app_key="api_key")

    @fixture(autouse=True)
    def HubSpot(self, patch):
        return patch("report.data_sources.hubspot_client.HubSpot")


class TestDummyHubspotClient:
    # Some basic coverage
    def test_get_companies(self):
        companies = [{"company": 1}]

        client = DummyHubspotClient(companies)

        assert client.get_companies() == companies

    def test_import_csv(self):
        DummyHubspotClient(None).import_csv()
