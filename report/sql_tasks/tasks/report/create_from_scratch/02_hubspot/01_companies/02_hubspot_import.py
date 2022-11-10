import os

from report.data_sources.hubspot_client import HubspotClient
from report.sql_tasks.sql_query import SQLQuery
from report.sql_tasks.timer import Timer

FIELD_MAPPING = {
    # General
    "hs_object_id": int,
    "name": None,
    "lms_organization_id": None,
    # Cohort
    "cohort__pilot_first_date": None,
    "cohort__subscription_first_date": None,
    # Deals
    "current_deal__services_start": None,
    "current_deal__services_end": None,
    "current_deal__amount": float,
    "current_deal__users_contracted": None,
    "deals_last_update": None,
}

INSERT_QUERY = """
   INSERT INTO hubspot.companies (
       id,
       name,
       lms_organization_id,

       cohort_pilot_first_date,
       cohort_subscription_first_date,

       current_deal_services_start,
       current_deal_services_end,
       current_deal_amount,
       current_deal_users_contracted,
       deals_last_update
   ) VALUES (
       :hs_object_id,
       :name,
       :lms_organization_id,

       :cohort__pilot_first_date,
       :cohort__subscription_first_date,

       :current_deal__services_start,
       :current_deal__services_end,
       :current_deal__amount,
       :current_deal__users_contracted,
       :deals_last_update
   )
"""


def _get_dsn(env_var_name):
    return os.environ[env_var_name].strip()


def _get_companies(api_client):
    for company in api_client.get_companies(list(FIELD_MAPPING.keys())):
        for key, mapping in FIELD_MAPPING.items():
            value = company[key] or None
            if mapping and value:
                value = mapping(value)

            company[key] = value

        yield company


def main(connection, **kwargs):
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    # Do everything about companies before we start, so we don't kill the DB,
    # then have a long pause before we put things back in.
    print("Getting Hubspot company data...")
    companies = list(_get_companies(api_client))

    query = SQLQuery(0, "TRUNCATE hubspot.companies;")
    query.execute(connection)
    print(query.dump(indent="    ") + "\n")

    timer = Timer()
    with timer.time_it():
        for company in companies:
            query = SQLQuery(1, INSERT_QUERY)
            query.execute(connection, parameters=company)

    print(f"Companies loaded in: {timer.duration}")
