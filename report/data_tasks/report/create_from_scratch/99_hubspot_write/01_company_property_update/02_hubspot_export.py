import csv
import os
import warnings
from tempfile import NamedTemporaryFile

from data_tasks.sql_query import SQLQuery

from report.data_sources.hubspot_client import HubspotClient


def main(connection, **kwargs):
    """
    Write our LMS properties back to Hubspot.

    This will populate various properties in the left hand sidebar of the
    company view with values defined by the view `company_property_update`.
    """
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    # Read the view. We will insert this verbatim
    query = SQLQuery(0, "SELECT * FROM hubspot.company_property_update")
    query.execute(connection)
    print(query.dump())

    if not query.rows:
        warnings.warn("No rows to export to Hubspot!")
        return

    with NamedTemporaryFile(mode="w", suffix=".csv") as csv_file:
        print(f"Writing final CSV to {csv_file.name}...")
        writer = csv.writer(csv_file)
        writer.writerow(query.columns)

        for row in query.rows:
            writer.writerow(row)

        # Ensure all rows are written to disk before we start to upload
        csv_file.flush()

        api_client.import_csv(
            job_name="Report Export",
            csv_files=[csv_file.name],
            object_type=HubspotClient.ObjectType.COMPANY,
        )

        print("Uploaded to Hubspot")
