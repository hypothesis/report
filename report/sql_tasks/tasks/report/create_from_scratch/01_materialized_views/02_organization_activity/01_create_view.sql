DROP MATERIALIZED VIEW IF EXISTS organization_activity CASCADE;

CREATE MATERIALIZED VIEW organization_activity AS (
    SELECT
        timescale,
        timestamp,
        period,
        role,
        CONCAT('us-', organization_id) AS organization_id,
        annotation_count,
        annotation_count_growth,
        active,
        active_growth,
        billable,
        billable_growth
    FROM lms_us.organization_activity

    UNION ALL

    SELECT
        timescale,
        timestamp,
        period,
        role,
        CONCAT('ca-', organization_id) AS organization_id,
        annotation_count,
        annotation_count_growth,
        active,
        active_growth,
        billable,
        billable_growth
    FROM lms_ca.organization_activity
) WITH NO DATA;
