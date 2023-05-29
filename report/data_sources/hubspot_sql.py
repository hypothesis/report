import csv
import warnings
from tempfile import NamedTemporaryFile
from typing import Iterable, List

from data_tasks.sql_query import SQLQuery
from data_tasks.timer import Timer

from report.data_sources.hubspot_client import Field, HubspotClient


def import_to_table(connection, table_name, items: List[dict], fields: Iterable[Field]):
    """
    Store a series of items as dicts in a given table.

    :param connection: DB connection
    :param table_name: Name of the table to store results
    :param items: Items as dicts to store
    :param fields: List of fields to store from the items
    """

    query = SQLQuery(0, f"TRUNCATE {table_name}")
    query.execute(connection)

    columns = ", ".join([field.key for field in fields])
    params = ", ".join([f":{field.key}" for field in fields])
    insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({params})"

    timer = Timer()
    with timer.time_it():
        for position, item in enumerate(items):
            query = SQLQuery(1 + position, insert_query)
            query.execute(connection, parameters=item)

    print(f"{len(items)} {table_name} loaded in: {timer.duration}")


def export_from_table(
    connection, api_client: HubspotClient, table_name, object_type, hubspot_job_name
):
    """
    Upload rows from a given table or view to Hubspot.

    :param connection: DB connection
    :param api_client: Hubspot client
    :param table_name: Name of table or view to read items from
    :param object_type: The `HubspotClient.ObjectType` type uploading
    :param hubspot_job_name: Name to give when uploading to Hubspot. This will
        show up in the list of imports in Hubspot.
    """

    # Read the table. We will insert this verbatim
    query = SQLQuery(0, f"SELECT * FROM {table_name}")
    query.execute(connection)

    if not query.rows:
        warnings.warn(f"No rows to export to Hubspot for {hubspot_job_name}!")
        return

    with NamedTemporaryFile(mode="w", suffix=".csv") as csv_file:
        print(f"Writing CSV to {csv_file.name} for {hubspot_job_name}...")
        print(f"\tWriting {len(query.rows)} rows")
        writer = csv.writer(csv_file)
        writer.writerow(query.columns)

        for row in query.rows:
            writer.writerow(row)

        # Ensure all rows are written to disk before we start to upload
        csv_file.flush()

        api_client.import_csv(
            job_name=hubspot_job_name,
            csv_files=[csv_file.name],
            object_type=object_type,
        )
