import os
from typing import Iterable

from data_tasks.sql_query import SQLQuery
from data_tasks.timer import Timer

from report.data_sources.hubspot_client import Field, HubspotClient


def _insert_items(connection, table_name, items, fields: Iterable[Field]):
    query = SQLQuery(0, f"TRUNCATE {table_name}")
    query.execute(connection)
    print(query.dump(indent="    ") + "\n")

    columns = ", ".join([field.key for field in fields])
    params = ", ".join([f":{field.key}" for field in fields])
    insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({params})"

    timer = Timer()
    with timer.time_it():
        for item in items:
            query = SQLQuery(1, insert_query)
            query.execute(connection, parameters=item)

    print(f"{len(items)} {table_name} loaded in: {timer.duration}")


COMPANY_FIELDS = (
    Field("hs_object_id", "id", mapping=int),
    Field("name"),
    Field("lms_organization_id"),
    # Cohort
    Field("cohort__pilot_first_date", "cohort_pilot_first_date"),
    Field("cohort__subscription_first_date", "cohort_subscription_first_date"),
    # Deals
    Field("current_deal__services_start", "current_deal_services_start"),
    Field("current_deal__services_end", "current_deal_services_end"),
    Field("current_deal__amount", "current_deal_amount", mapping=float),
    Field("current_deal__users_contracted", "current_deal_users_contracted"),
)

# The API docs link you here, but it doesn't show the API keys for properties
# https://knowledge.hubspot.com/crm-deals/hubspots-default-deal-properties
DEAL_FIELDS = (
    Field("hs_object_id", "id", mapping=int),
    Field("dealname", "name"),
    Field("services_start"),
    Field("services_end"),
    # We really should have currency, but I can't work out the name for it
    Field("amount", mapping=float),
)

COMPANY_DEAL_FIELDS = (
    Field("company_id", mapping=int),
    Field("deal_id", mapping=int),
)


def main(connection, **kwargs):
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    # Do everything about getting data before we start, so we don't kill the
    # DB, then have a long pause before we put things back in. This might eat
    # some memory. So we could stream to disk if required or something.
    print("Getting Hubspot data...")

    print("\tCompanies...")
    companies = list(api_client.get_companies(COMPANY_FIELDS))

    print("\tDeals...")
    deals = list(api_client.get_deals(DEAL_FIELDS))

    print("\tCompany deal associations...")
    company_deals = [
        {"company_id": company_id, "deal_id": deal_id}
        for company_id, deal_id in api_client.get_associations(
            from_type=api_client.AssociationObjectType.COMPANY,
            to_type=api_client.AssociationObjectType.DEAL,
            object_ids=[company["id"] for company in companies],
        )
    ]

    print("Inserting Hubspot company data...")

    print("\tCompanies...")
    _insert_items(
        connection,
        table_name="hubspot.companies",
        items=companies,
        fields=COMPANY_FIELDS,
    )

    print("\tDeals...")
    _insert_items(
        connection, table_name="hubspot.deals", items=deals, fields=DEAL_FIELDS
    )

    print("\tCompany deal associations...")
    _insert_items(
        connection,
        table_name="hubspot.company_deals",
        items=company_deals,
        fields=COMPANY_DEAL_FIELDS,
    )
