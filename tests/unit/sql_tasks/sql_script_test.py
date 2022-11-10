from unittest.mock import create_autospec, sentinel

import pytest
from importlib_resources import files

from report.sql_tasks.sql_query import SQLQuery
from report.sql_tasks.sql_script import SQLScript


class TestSQLScript:
    def test_from_dir(self):
        fixture_dir = files("tests.unit.sql_tasks") / "script_fixture"

        template_vars = {"template_var": "template_value"}

        scripts = list(
            SQLScript.from_dir(task_dir=str(fixture_dir), template_vars=template_vars)
        )

        assert scripts == [
            SQLScript(
                path=str(fixture_dir / "01_file.sql"),
                template_vars=template_vars,
                queries=[
                    SQLQuery(index=0, text="-- Comment 1\nSELECT 1;"),
                    SQLQuery(index=1, text="-- Comment 2\nSELECT 2;"),
                ],
            ),
            SQLScript(
                path=str(fixture_dir / "02_dir/01_file.sql"),
                template_vars=template_vars,
                queries=[SQLQuery(index=0, text="SELECT 3")],
            ),
            SQLScript(
                path=str(fixture_dir / "03_file.jinja2.sql"),
                template_vars=template_vars,
                queries=[SQLQuery(index=0, text="SELECT 'template_value';")],
            ),
        ]

    def test_from_dir_raises_for_missing_dir(self):
        with pytest.raises(NotADirectoryError):
            list(SQLScript.from_dir("/i_do_not_exist", {}))

    def test_dump(self):
        script = SQLScript(path="/long/path", template_vars={}, queries=[...])

        assert "/long/path" in script.dump()

    def test_execute(self):
        query = create_autospec(SQLQuery, spec_set=True, instance=True)
        script = SQLScript(path="/long/path", template_vars={}, queries=[query])

        items = list(script.execute(sentinel.connection))

        assert items == [query, script]
        query.execute.assert_called_once_with(sentinel.connection)
