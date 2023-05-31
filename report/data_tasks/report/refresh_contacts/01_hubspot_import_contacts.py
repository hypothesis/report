import os

from report.data_sources.hubspot.client import Field, HubspotClient
from report.data_sources.hubspot.sql import import_to_table

CONTACT_FIELDS = (
    Field("hs_object_id", "id", mapping=int),
    # Lower case the email as we store it to simplify comparisons
    Field("email", mapping=lambda email: email.lower()),
)


def main(connection, **kwargs):
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    print("Getting Hubspot contact data...")
    contacts = list(api_client.get_contacts(CONTACT_FIELDS))

    import_to_table(
        connection=connection,
        table_name="hubspot.contacts",
        items=contacts,
        fields=CONTACT_FIELDS,
    )
