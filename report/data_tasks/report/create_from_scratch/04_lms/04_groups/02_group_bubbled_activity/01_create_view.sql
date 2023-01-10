DROP MATERIALIZED VIEW IF EXISTS lms.group_bubbled_activity CASCADE;

CREATE MATERIALIZED VIEW lms.group_bubbled_activity AS (
    SELECT
        created_week,
        CONCAT('us-', group_id) as group_id,
        annotation_count,
        annotation_shared_count,
        annotation_replies_count,
        launch_count
    FROM lms_us.group_bubbled_activity

    UNION ALL

    SELECT
        created_week,
        CONCAT('ca-', group_id) as group_id,
        annotation_count,
        annotation_shared_count,
        annotation_replies_count,
        launch_count
    FROM lms_ca.group_bubbled_activity
) WITH NO DATA;
