DROP INDEX IF EXISTS organization_activity_region_timescale_created_org_id_idx;

REFRESH MATERIALIZED VIEW organization_activity;

ANALYSE organization_activity;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_activity_region_timescale_created_org_id_idx ON organization_activity (region, timescale, period, role, organization_id);
