import os
from operator import itemgetter

from report.data_sources.hubspot.client import Field, HubspotClient
from report.data_sources.hubspot.sql import import_to_table

# The API docs link you here, but it doesn't show the API keys for properties
# https://knowledge.hubspot.com/companies/hubspot-crm-default-company-properties
# Use `api_client.get_properties(api_client.ObjectType.COMPANY)` to get details
COMPANY_FIELDS = (
    Field("hs_object_id", "id", mapping=int),
    Field("name"),
    Field("lms_organization_id"),
    # Owners
    Field("hubspot_owner_id", "company_owner_id", mapping=int),
    Field("owner__success", "success_owner_id", mapping=int),
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
# Use `api_client.get_properties(api_client.ObjectType.DEAL)` to get details
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


def filter_owner(owner):
    """Convert the values that come from Hubspot into the shape we want."""

    first_name = owner["first_name"]
    last_name = owner["last_name"]
    email = owner["email"]

    # Try and cobble together a representative name
    if first_name and last_name:
        name = f"{first_name} {last_name}"
    elif first_name or last_name:
        name = first_name or last_name
    elif email:
        name = email.split("@")[0].title()
    else:
        name = None

    return {
        "id": owner["id"],
        "first_name": first_name or None,
        "last_name": last_name or None,
        "name": name,
        "email": email or None,
        "archived": bool(owner["archived"]),
    }


OWNERS_FIELDS = (
    Field("id"),
    Field("first_name"),
    Field("last_name"),
    Field("name"),
    Field("email"),
    Field("archived"),
)


def filter_team(team):
    """Convert the values that come from Hubspot into the shape we want."""

    return {"id": int(team["id"]), "name": team["name"]}


TEAMS_FIELDS = (Field("id"), Field("name"))

OWNER_TEAMS_FIELDS = (Field("owner_id"), Field("team_id"))


def main(connection, **kwargs):
    api_client = HubspotClient(private_app_key=os.environ["HUBSPOT_API_KEY"])

    # Do everything about getting data before we start, so we don't kill the
    # DB, then have a long pause before we put things back in. This might eat
    # some memory. So we could stream to disk if required or something.
    print("Getting Hubspot data...")

    print("\tGetting owners and teams...")

    owners = list(api_client.get_owners())
    owner_teams, teams = api_client.parse_teams_from_owners(owners)
    owners = [filter_owner(owner) for owner in owners]
    owners = list(sorted(owners, key=itemgetter("id")))
    teams = [filter_team(teams) for teams in teams]
    teams = list(sorted(teams, key=itemgetter("id")))

    print("\tCompanies...")
    companies = list(api_client.get_companies(COMPANY_FIELDS))

    print("\tDeals...")
    deals = list(api_client.get_deals(DEAL_FIELDS))
    _sort_deal_dates(deals)

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

    print("\tOwners...")
    import_to_table(
        connection=connection,
        table_name="hubspot.owners",
        items=owners,
        fields=OWNERS_FIELDS,
    )

    print("\tTeams...")
    import_to_table(
        connection=connection,
        table_name="hubspot.teams",
        items=teams,
        fields=TEAMS_FIELDS,
    )

    print("\tOwner teams...")
    import_to_table(
        connection=connection,
        table_name="hubspot.owner_teams",
        items=owner_teams,
        fields=OWNER_TEAMS_FIELDS,
    )

    print("\tCompanies...")
    import_to_table(
        connection=connection,
        table_name="hubspot.companies",
        items=companies,
        fields=COMPANY_FIELDS,
    )

    print("\tDeals...")
    import_to_table(
        connection=connection,
        table_name="hubspot.deals",
        items=deals,
        fields=DEAL_FIELDS,
    )

    print("\tCompany deal associations...")
    import_to_table(
        connection=connection,
        table_name="hubspot.company_deals",
        items=company_deals,
        fields=COMPANY_DEAL_FIELDS,
    )


def _sort_deal_dates(deals):
    """Ensure the start of a deal comes before the end.

    This should be true, but as these values are entered by people there's
    nothing really stopping them from being put in backwards, which will cause
    Postgres conniptions
    """
    for deal in deals:
        services_start, services_end = deal["services_start"], deal["services_end"]
        if services_start and services_end:
            deal["services_start"] = min(services_start, services_end)
            deal["services_end"] = max(services_start, services_end)
