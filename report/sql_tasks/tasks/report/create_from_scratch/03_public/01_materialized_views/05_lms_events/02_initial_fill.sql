DROP INDEX IF EXISTS lms_events_timestamp_week_region_organization_id_event_type_idx;

REFRESH MATERIALIZED VIEW lms_events;

ANALYSE lms_events;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX lms_events_timestamp_week_region_organization_id_event_type_idx ON lms_events (timestamp_week, region, organization_id, event_type, user_id);
