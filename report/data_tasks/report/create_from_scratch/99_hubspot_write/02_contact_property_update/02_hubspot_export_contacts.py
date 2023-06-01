import os

from report.data_sources.hubspot.client import HubspotClient
from report.data_sources.hubspot.sql import export_from_table


def main(connection, **kwargs):
    """
    Write properties back to Hubspot for contacts.

    This will populate various properties in the left hand sidebar of the
    contact view with values defined by the view `contact_property_update`.
    """
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    export_from_table(
        connection=connection,
        api_client=api_client,
        table_name="hubspot.contact_property_update",
        object_type=HubspotClient.ObjectType.CONTACT,
        hubspot_job_name="Report Contact Export",
    )
