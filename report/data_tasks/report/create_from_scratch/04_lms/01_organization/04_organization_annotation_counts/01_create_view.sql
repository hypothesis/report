DROP MATERIALIZED VIEW IF EXISTS lms.organization_annotation_counts CASCADE;

CREATE MATERIALIZED VIEW lms.organization_annotation_counts AS (
    SELECT
        timescale,
        start_date,
        end_date,
        period,
        CONCAT('us-', organization_id) AS organization_id,
        role,
        sub_type,
        shared,
        count
    FROM lms_us.organization_annotation_counts

    UNION ALL

    SELECT
        timescale,
        start_date,
        end_date,
        period,
        CONCAT('ca-', organization_id) AS organization_id,
        role,
        sub_type,
        shared,
        count
    FROM lms_ca.organization_annotation_counts
) WITH NO DATA;
