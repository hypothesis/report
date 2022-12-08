DROP INDEX IF EXISTS lms.organization_activity_region_timescale_created_org_id_idx;
DROP INDEX IF EXISTS lms.organization_activity_start_date_end_date_idx;

REFRESH MATERIALIZED VIEW lms.organization_activity;

ANALYSE lms.organization_activity;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_activity_region_timescale_created_org_id_idx ON lms.organization_activity (timescale, period, role, organization_id);
CREATE INDEX organization_activity_start_date_end_date_idx ON lms.organization_activity (start_date, end_date);
