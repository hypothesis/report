import json
from dataclasses import dataclass
from http import HTTPStatus
from unittest.mock import MagicMock, call, create_autospec, sentinel

import pytest
from h_matchers import Any
from hubspot.crm.associations import (
    AssociatedId,
    BatchResponsePublicAssociationMulti,
    PublicAssociationMulti,
)
from hubspot.crm.contacts import Filter, FilterGroup, PublicObjectSearchRequest
from hubspot.crm.objects.exceptions import ApiException
from pytest import fixture

from report.data_sources.hubspot.client import (
    RATE_LIMIT_SECONDS,
    Field,
    HubspotClient,
    date_or_timestamp,
)


@dataclass
class FakeApiObject:
    properties: dict


@pytest.mark.parametrize(
    "value,expected", [("2019-03-01", "2019-03-01"), ("1551398400000", "2019-03-01")]
)
def test_date_or_timestamp(value, expected):
    assert date_or_timestamp(value) == expected


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
        "api_method,method",
        (
            ("companies", "get_companies"),
            ("contacts", "get_contacts"),
            ("deals", "get_deals"),
        ),
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

        ids = client.get_associations(
            from_type=client.AssociationObjectType.COMPANY,
            to_type=client.AssociationObjectType.DEAL,
            object_ids=[123, "123", "456"],
        )
        # pylint:disable=no-value-for-parameter
        BatchInputPublicObjectId.assert_called_once_with(
            inputs=Any.list.containing(["123", "456"]).only()
        )
        client.api_client.crm.associations.batch_api.read.assert_called_once_with(
            from_object_type=client.AssociationObjectType.COMPANY.value,
            to_object_type=client.AssociationObjectType.DEAL.value,
            batch_input_public_object_id=BatchInputPublicObjectId.return_value,
        )

        result = batch_response.results[0]
        assert ids == {
            # pylint: disable=protected-access
            (result._from.id, result.to[0].id),
            (result._from.id, result.to[1].id),
        }

    def test_get_associations_batches_calls(self, client, BatchInputPublicObjectId):
        client.get_associations(
            from_type=client.AssociationObjectType.COMPANY,
            to_type=client.AssociationObjectType.DEAL,
            object_ids=list(range(client.ASSOCIATIONS_BATCH_SIZE + 10)),
        )
        BatchInputPublicObjectId.assert_has_calls(
            [
                call(inputs=Any.list.of_size(client.ASSOCIATIONS_BATCH_SIZE)),
                call(inputs=Any.list.of_size(10)),
            ]
        )

        assert client.api_client.crm.associations.batch_api.read.call_count == 2

    def test_get_contacts_by_email(self, client):
        result_item = MagicMock(properties={"hs_object_id": 1234})
        client.api_client.crm.contacts.search_api.do_search.return_value = MagicMock(
            results=[result_item]
        )

        result = list(
            client.get_contacts_by_email(
                emails=["email@example.com"], fields=[Field("hs_object_id", "id")]
            )
        )

        filter_ = Filter(
            property_name="email", operator="IN", values=["email@example.com"]
        )
        client.api_client.crm.contacts.search_api.do_search.assert_called_once_with(
            PublicObjectSearchRequest(
                limit=100,
                properties=["hs_object_id"],
                filter_groups=[FilterGroup(filters=[filter_])],
            )
        )
        assert result == [{"id": 1234}]

    def test_get_contact_raises_retries_rate_limiting(self, client, time):
        retry_exception = ApiException(status=HTTPStatus.TOO_MANY_REQUESTS)
        client.api_client.crm.contacts.search_api.do_search.side_effect = [
            retry_exception
        ] * 5 + [MagicMock(results=[MagicMock(properties={"id": 1234})])]

        result = list(
            client.get_contacts_by_email(
                emails=["email@example.com"], fields=[Field("id")]
            )
        )

        assert client.api_client.crm.contacts.search_api.do_search.call_count == 6
        time.sleep.assert_has_calls([call(RATE_LIMIT_SECONDS)] * 5)
        assert result == [{"id": 1234}]

    @pytest.mark.usefixtures("time")
    def test_get_contact_raises_with_infinite_rate_limiting(self, client):
        client.api_client.crm.contacts.search_api.do_search.side_effect = ApiException(
            status=HTTPStatus.TOO_MANY_REQUESTS
        )

        with pytest.raises(ApiException):
            list(
                client.get_contacts_by_email(
                    emails=["email@example.com"], fields=[Field("id")]
                )
            )

    def test_get_contact_with_100_results(self, client):
        # This is mostly to hit some coverage, we don't actually make any
        # assertions about the result
        client.api_client.crm.contacts.search_api.do_search.return_value = MagicMock(
            results=[MagicMock(properties={"id": 1234})] * 100
        )

        list(
            client.get_contacts_by_email(
                emails=["email@example.com"], fields=[Field("id")]
            )
        )

    def test_get_contact_raises_random_exceptions(self, client):
        client.api_client.crm.contacts.search_api.do_search.side_effect = ValueError

        with pytest.raises(ValueError):
            list(
                client.get_contacts_by_email(
                    emails=["email@example.com"], fields=[Field("id")]
                )
            )

    def test_get_owners(self, client):
        owner = MagicMock()
        client.api_client.crm.owners.get_all.return_value = (owner,)

        response = list(client.get_owners())

        client.api_client.crm.owners.get_all.assert_called_once_with()
        owner.to_dict.assert_called_once_with()
        assert response == [owner.to_dict.return_value]

    def test_get_properties(self, client):
        prop = MagicMock()
        client.api_client.crm.properties.core_api.get_all.return_value.results = (prop,)

        response = list(client.get_properties(sentinel.object_type))

        client.api_client.crm.properties.core_api.get_all.assert_called_once_with(
            sentinel.object_type
        )
        prop.to_dict.assert_called_once_with()
        assert response == [prop.to_dict.return_value]

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
                    "dateFormat": "YEAR_MONTH_DAY",
                }
            ),
            files=[csv_file],
            async_req=False,
        )

        assert result == create.return_value

    def test_parse_teams_from_owners(self, client):
        owners = [
            {"id": "123", "teams": [{"id": "321", "key": "value"}]},
            {"id": 456, "teams": [{"id": "321", "key": "value"}]},
            {"id": 789, "teams": []},
        ]

        owner_team, teams = client.parse_teams_from_owners(owners)

        assert owner_team == [
            {"owner_id": 123, "team_id": 321},
            {"owner_id": 456, "team_id": 321},
        ]
        assert teams == [{"id": 321, "key": "value"}]

    @pytest.fixture
    def time(self, patch):
        return patch("report.data_sources.hubspot.client.time")

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
        result = create_autospec(
            PublicAssociationMulti,
            spec_set=True,
            instance=True,
            to=[
                create_autospec(AssociatedId, spec_set=True, instance=True),
                create_autospec(AssociatedId, spec_set=True, instance=True),
            ],
        )

        return create_autospec(
            BatchResponsePublicAssociationMulti,
            spec_set=True,
            instance=True,
            # We put in the same result twice to test deduping
            results=[result, result],
        )

    @fixture
    def BatchInputPublicObjectId(self, patch):
        return patch("report.data_sources.hubspot.client.BatchInputPublicObjectId")

    @fixture(autouse=True)
    def HubSpot(self, patch):
        return patch("report.data_sources.hubspot.client.HubSpot")
