from unittest.mock import Mock, call, create_autospec, sentinel

import pytest
from h_matchers import Any

from report.data_sources.hubspot.client import Field, HubspotClient
from report.data_sources.hubspot.sql import export_from_table, import_to_table


class TestSQLMethods:
    def test_import_to_table(self, connection, SQLQuery):
        items = [{"field_1": "a1", "field_2": "a2"}, {"field_1": "b1", "field_2": "b2"}]

        import_to_table(
            connection=connection,
            table_name="table_name",
            items=items,
            fields=[Field("field_1"), Field("field_2")],
        )

        update_query = (
            "INSERT INTO table_name (field_1, field_2) VALUES (:field_1, :field_2)"
        )
        SQLQuery.assert_has_calls(
            [
                call(0, "TRUNCATE table_name"),
                call().execute(connection),
                call(1, update_query),
                call().execute(connection, parameters=items[0]),
                call(2, update_query),
                call().execute(connection, parameters=items[1]),
            ]
        )

    def test_export_from_table(self, connection, api_client, SQLQuery):
        SQLQuery.return_value.columns = ["id", "text"]
        SQLQuery.return_value.rows = [[1, "Hello 1"], [2, "Hello 2"]]

        # pylint: disable=unused-argument
        def import_csv(job_name, csv_files, object_type):
            assert len(csv_files) == 1
            with open(csv_files[0], encoding="utf-8") as handle:
                assert handle.read() == "id,text\n1,Hello 1\n2,Hello 2\n"

        api_client.import_csv.side_effect = import_csv

        export_from_table(
            connection=connection,
            api_client=api_client,
            table_name="table_name",
            object_type=sentinel.object_type,
            hubspot_job_name="Job Name",
        )

        SQLQuery.assert_called_once_with(0, "SELECT * FROM table_name")
        SQLQuery.return_value.execute.assert_called_once_with(connection)
        api_client.import_csv.assert_called_once_with(
            job_name="Job Name",
            csv_files=[Any.string()],
            object_type=sentinel.object_type,
        )

    def test_export_from_table_with_no_rows(self, connection, api_client, SQLQuery):
        SQLQuery.return_value.columns = ["id", "text"]
        SQLQuery.return_value.rows = []

        with pytest.warns():
            export_from_table(
                connection=connection,
                api_client=api_client,
                table_name="table_name",
                object_type=sentinel.object_type,
                hubspot_job_name="Job Name",
            )

        api_client.import_csv.assert_not_called()

    @pytest.fixture
    def connection(self):
        return Mock()

    @pytest.fixture
    def api_client(self):
        return create_autospec(HubspotClient, instance=True, spec_set=True)

    @pytest.fixture(autouse=True)
    def SQLQuery(self, patch):
        return patch("report.data_sources.hubspot.sql.SQLQuery")
