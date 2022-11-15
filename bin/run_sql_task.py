"""
Task runner for tasks written as SQL files in directories.

This is a general mechanism for running tasks defined in SQL, however it's
currently only used to perform the aggregations and mappings required for
reporting.
"""

import os
from argparse import ArgumentParser

import importlib_resources
import sqlalchemy
from psycopg2.extensions import parse_dsn

from report import sql_tasks
from report.sentry import load_sentry
from report.sql_tasks.python_script import PythonScript

TASK_ROOT = importlib_resources.files("report.sql_tasks") / "tasks"

parser = ArgumentParser(
    description=f"A script for running SQL tasks defined in: {TASK_ROOT}"
)
parser.add_argument("-t", "--task", required=True, help="The SQL task name to run")
parser.add_argument(
    "--no-python",
    action="store_const",
    default=False,
    const=True,
    help="Skip Python executables",
)
parser.add_argument(
    "--dry-run",
    action="store_const",
    default=False,
    const=True,
    help="Run through the task without executing anything for real",
)


def _get_dsn(env_var_name):
    return os.environ[env_var_name].strip()


def main():
    load_sentry()

    args = parser.parse_args()
    dsn = _get_dsn("DATABASE_URL")

    scripts = sql_tasks.from_dir(
        task_dir=TASK_ROOT / args.task,
        template_vars={
            "db_user": parse_dsn(dsn)["user"],
            "metabase_db_user": os.environ["MB_DB_USER"],
            "fdw": {
                "h_us": parse_dsn(_get_dsn("H_US_DATABASE_URL")),
                "h_ca": parse_dsn(_get_dsn("H_CA_DATABASE_URL")),
                "lms_us": parse_dsn(_get_dsn("LMS_US_DATABASE_URL")),
                "lms_ca": parse_dsn(_get_dsn("LMS_CA_DATABASE_URL")),
            },
        },
    )

    engine = sqlalchemy.create_engine(dsn)

    # Run the update in a transaction, so we roll back if it goes wrong
    with engine.connect() as connection:
        with connection.begin():
            for script in scripts:
                if args.no_python and isinstance(script, PythonScript):
                    print(f"Skipping: {script}")
                    continue

                for step in script.execute(connection, dry_run=args.dry_run):
                    if args.dry_run:
                        print("Dry run!")

                    print(step.dump(indent="    ") + "\n")


if __name__ == "__main__":
    main()
