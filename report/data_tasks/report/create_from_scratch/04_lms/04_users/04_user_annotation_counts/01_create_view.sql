DROP MATERIALIZED VIEW IF EXISTS lms.user_annotation_counts CASCADE;

CREATE MATERIALIZED VIEW lms.user_annotation_counts AS (
    SELECT
        created_week,
        CONCAT('us-', user_id) as user_id,
        CONCAT('us-', group_id) as group_id,
        sub_type,
        shared,
        count
    FROM lms_us.user_annotation_counts

    UNION ALL

    SELECT
        created_week,
        CONCAT('ca-', user_id) as user_id,
        CONCAT('ca-', group_id) as group_id,
        sub_type,
        shared,
        count
    FROM lms_ca.user_annotation_counts
) WITH NO DATA;
