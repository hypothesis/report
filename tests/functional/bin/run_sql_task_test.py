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
    @pytest.mark.xfail(reason="Requires create_from_scratch in H and LMS")
    def test_reporting_tasks(self, environ):
        for task_name in (
            "report/create_from_scratch",
            "report/refresh",
            "report/create_from_scratch",
        ):
            result = check_output(
                [
                    sys.executable,
                    "bin/run_sql_task.py",
                    "--task",
                    task_name,
                    "--no-python",
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
