DROP MATERIALIZED VIEW IF EXISTS organizations CASCADE;

CREATE MATERIALIZED VIEW organizations AS (
    SELECT
        CONCAT('us-', id) AS id,
        CONCAT('us.lms.org.', public_id) AS public_id,
        name,
        'us' AS region,
        created,
        updated,
        enabled
    FROM lms_us.organization

    UNION ALL

    SELECT
        CONCAT('ca-', id) AS id,
        CONCAT('ca.lms.org.', public_id) AS public_id,
        name,
        'ca' AS region,
        created,
        updated,
        enabled
    FROM lms_ca.organization
) WITH NO DATA;