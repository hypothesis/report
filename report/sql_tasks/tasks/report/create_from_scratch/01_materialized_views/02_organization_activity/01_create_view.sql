DROP MATERIALIZED VIEW IF EXISTS organization_activity CASCADE;

CREATE MATERIALIZED VIEW organization_activity AS (
    SELECT 'us' AS region, * FROM lms_us.organization_activity

    UNION

    SELECT 'ca' AS region, * FROM lms_ca.organization_activity
) WITH NO DATA;
