DROP INDEX IF EXISTS lms.group_bubbled_activity_group_id_created_week_idx;

REFRESH MATERIALIZED VIEW lms.group_bubbled_activity;

ANALYSE lms.group_bubbled_activity;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX group_bubbled_activity_group_id_created_week_idx ON lms.group_bubbled_activity (group_id, created_week);
