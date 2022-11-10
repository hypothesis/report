DROP INDEX IF EXISTS hubspot.company_activity_timescale_period_company_id_idx;

REFRESH MATERIALIZED VIEW hubspot.deals;

-- We should have a unique index below this, but there's nothing to index on
-- for the fake deals
ANALYSE hubspot.deals;