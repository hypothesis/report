import os
import sys
from subprocess import check_output

import pytest
from importlib_resources import files
from pytest import fixture

from tests.functional.conftest import TEST_ENVIRONMENT


class TestRunSQLTask:
    # We use "clean DB" here to ensure the schema is created
    @pytest.mark.usefixtures("with_clean_db")
    @pytest.mark.parametrize(
        "task_name",
        [
            "hello_world",
            pytest.param(
                "report/create_from_scratch",
                marks=pytest.mark.xfail(reason="Dependency on other DBs"),
            ),
        ],
    )
    def test_reporting_tasks(self, environ, task_name):
        result = check_output(
            [
                sys.executable,
                "bin/run_sql_task.py",
                "--task",
                task_name,
            ],
            env=environ,
        )

        assert result

        print(f"Task {task_name} OK!")
        print(result.decode("utf-8"))

    @fixture
    def environ(self):
        environ = dict(os.environ)

        environ["PYTHONPATH"] = "."
        environ.update(TEST_ENVIRONMENT)

        return environ

    @fixture(autouse=True)
    def run_in_root(self):
        # A context manager to ensure we work from the root, but return the
        # path to where it was before
        current_dir = os.getcwd()
        os.chdir(str(files("report") / ".."))

        yield

        os.chdir(current_dir)
