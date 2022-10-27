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

from report.sql_tasks.sql_script import SQLScript

TASK_ROOT = importlib_resources.files("report.sql_tasks") / "tasks"

parser = ArgumentParser(
    description=f"A script for running SQL tasks defined in: {TASK_ROOT}"
)
parser.add_argument("-t", "--task", required=True, help="The SQL task name to run")


def main():
    args = parser.parse_args()

    dsn = os.environ["DATABASE_URL"].strip()

    scripts = SQLScript.from_dir(
        task_dir=TASK_ROOT / args.task,
        template_vars={"db_user": parse_dsn(dsn)["user"]},
    )

    engine = sqlalchemy.create_engine(dsn)

    # Run the update in a transaction, so we roll back if it goes wrong
    with engine.connect() as connection:
        with connection.begin():
            for script in scripts:
                print(f"Executing: {script.path}")

                for query in script.queries:
                    query.execute(connection)
                    print(query.dump(indent="    ") + "\n")


if __name__ == "__main__":
    main()
