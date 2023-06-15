DROP INDEX IF EXISTS lms.events_timestamp_week_region_organization_id_event_type_idx;

REFRESH MATERIALIZED VIEW lms.events;

ANALYSE lms.events;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX events_timestamp_week_region_organization_id_event_type_idx ON lms.events (timestamp_week, region, organization_id, event_type, user_id);
