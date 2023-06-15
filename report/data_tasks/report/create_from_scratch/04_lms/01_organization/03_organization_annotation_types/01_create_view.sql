DROP MATERIALIZED VIEW IF EXISTS lms.organization_annotation_types CASCADE;

CREATE MATERIALIZED VIEW lms.organization_annotation_types AS (
    SELECT
        timescale,
        start_date,
        end_date,
        period,
        CONCAT('us-', organization_id) AS organization_id,
        sub_type,
        shared,
        count
    FROM lms_us.organization_annotation_types

    UNION ALL

    SELECT
        timescale,
        start_date,
        end_date,
        period,
        CONCAT('ca-', organization_id) AS organization_id,
        sub_type,
        shared,
        count
    FROM lms_ca.organization_annotation_types
) WITH NO DATA;
