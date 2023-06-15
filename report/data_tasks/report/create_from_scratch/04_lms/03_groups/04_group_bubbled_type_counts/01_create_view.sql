DROP MATERIALIZED VIEW IF EXISTS lms.group_bubbled_type_counts CASCADE;

CREATE MATERIALIZED VIEW lms.group_bubbled_type_counts AS (
    SELECT
        created_week,
        CONCAT('us-', group_id) as group_id,
        sub_type,
        shared,
        count
    FROM lms_us.group_bubbled_type_counts

    UNION ALL

    SELECT
        created_week,
        CONCAT('ca-', group_id) as group_id,
        sub_type,
        shared,
        count
    FROM lms_ca.group_bubbled_type_counts
) WITH NO DATA;
