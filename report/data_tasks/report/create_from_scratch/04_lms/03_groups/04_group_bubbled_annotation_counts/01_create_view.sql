DROP MATERIALIZED VIEW IF EXISTS lms.group_bubbled_annotation_counts CASCADE;

CREATE MATERIALIZED VIEW lms.group_bubbled_annotation_counts AS (
    SELECT
        created_week,
        CONCAT('us-', group_id) as group_id,
        role,
        sub_type,
        shared,
        count
    FROM lms_us.group_bubbled_annotation_counts

    UNION ALL

    SELECT
        created_week,
        CONCAT('ca-', group_id) as group_id,
        role,
        sub_type,
        shared,
        count
    FROM lms_ca.group_bubbled_annotation_counts
) WITH NO DATA;
