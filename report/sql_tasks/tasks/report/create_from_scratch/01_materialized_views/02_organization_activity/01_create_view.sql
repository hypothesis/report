DROP MATERIALIZED VIEW IF EXISTS organization_activity CASCADE;

CREATE MATERIALIZED VIEW organization_activity AS (
    SELECT
        timescale,
        period,
        role,
        CONCAT('us-', organization_id) AS organization_id,
        annotation_count,
        active,
        billable
    FROM lms_us.organization_activity

    UNION ALL

    SELECT
        timescale,
        period,
        role,
        CONCAT('ca-', organization_id) AS organization_id,
        annotation_count,
        active,
        billable
    FROM lms_ca.organization_activity
) WITH NO DATA;
