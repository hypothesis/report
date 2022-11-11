import json
from dataclasses import dataclass
from unittest.mock import create_autospec

import pytest
from hubspot.crm.associations import (
    AssociatedId,
    BatchResponsePublicAssociationMulti,
    PublicAssociationMulti,
)
from pytest import fixture

from report.data_sources.hubspot_client import Field, HubspotClient


@dataclass
class FakeApiObject:
    properties: dict


class TestField:
    def test_it(self):
        field = Field(hs_field="name")
        assert field.key == "name"


class TestHubspotClient:
    def test___post_init__(self, client, HubSpot):
        HubSpot.assert_called_once_with()
        assert client.api_client == HubSpot.return_value
        assert client.api_client.access_token == "api_key"

    @pytest.mark.parametrize(
        "api_method,method", (("companies", "get_companies"), ("deals", "get_deals"))
    )
    def test_object_getters(self, client, api_method, method):
        getattr(client.api_client.crm, api_method).get_all.return_value = [
            FakeApiObject(
                {
                    "wanted": "value",
                    "unwanted": "bad_value",
                    "empty-as-null": "",
                    "none-not-mapped": None,
                }
            )
        ]

        results = getattr(client, method)(
            fields=[
                Field(
                    "wanted", "named-wanted", mapping=lambda string: f"mapped-{string}"
                ),
                Field("empty-as-null"),
                Field("none-not-mapped", mapping=int),
            ]
        )

        assert list(results) == [
            {
                "named-wanted": "mapped-value",
                "empty-as-null": None,
                "none-not-mapped": None,
            }
        ]

    def test_get_associations(self, client, batch_response, BatchInputPublicObjectId):
        client.api_client.crm.associations.batch_api.read.return_value = batch_response

        ids = list(
            client.get_associations(
                from_type=client.AssociationObjectType.COMPANY,
                to_type=client.AssociationObjectType.DEAL,
                object_ids=[123, "456"],
            )
        )

        BatchInputPublicObjectId.assert_called_once_with(inputs=["123", "456"])
        client.api_client.crm.associations.batch_api.read.assert_called_once_with(
            from_object_type=client.AssociationObjectType.COMPANY.value,
            to_object_type=client.AssociationObjectType.DEAL.value,
            batch_input_public_object_id=BatchInputPublicObjectId.return_value,
        )

        result = batch_response.results[0]
        assert ids == [
            # pylint: disable=protected-access
            (result._from.id, result.to[0].id),
            (result._from.id, result.to[1].id),
        ]

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

    @fixture
    def batch_response(self):
        return create_autospec(
            BatchResponsePublicAssociationMulti,
            spec_set=True,
            instance=True,
            results=[
                create_autospec(
                    PublicAssociationMulti,
                    spec_set=True,
                    instance=True,
                    to=[
                        create_autospec(AssociatedId, spec_set=True, instance=True),
                        create_autospec(AssociatedId, spec_set=True, instance=True),
                    ],
                )
            ],
        )

    @fixture
    def BatchInputPublicObjectId(self, patch):
        return patch("report.data_sources.hubspot_client.BatchInputPublicObjectId")

    @fixture(autouse=True)
    def HubSpot(self, patch):
        return patch("report.data_sources.hubspot_client.HubSpot")
