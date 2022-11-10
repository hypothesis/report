DROP INDEX IF EXISTS hubspot.company_activity_timescale_period_company_id_idx;

REFRESH MATERIALIZED VIEW hubspot.company_activity;

ANALYSE hubspot.company_activity;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX company_activity_timescale_period_company_id_idx ON hubspot.company_activity (timescale, period, company_id);