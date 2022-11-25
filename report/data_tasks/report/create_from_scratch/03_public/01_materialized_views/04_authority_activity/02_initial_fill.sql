DROP INDEX IF EXISTS authority_activity_timescale_period_authority_id_region_idx;
DROP INDEX IF EXISTS authority_activity_start_date_end_date_idx;

REFRESH MATERIALIZED VIEW authority_activity;

ANALYSE authority_activity;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX authority_activity_timescale_period_authority_id_region_idx ON authority_activity (timescale, period, authority_id, region);
CREATE INDEX authority_activity_start_date_end_date_idx ON authority_activity (start_date, end_date);
