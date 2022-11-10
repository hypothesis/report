-- Note there is no concurrently here, until we stop using fake deals
REFRESH MATERIALIZED VIEW hubspot.deals;
ANALYSE hubspot.deals;

REFRESH MATERIALIZED VIEW CONCURRENTLY hubspot.company_activity;
ANALYSE hubspot.company_activity;
