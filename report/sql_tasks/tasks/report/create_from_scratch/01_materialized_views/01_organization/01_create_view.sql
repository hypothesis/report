DROP MATERIALIZED VIEW IF EXISTS organizations CASCADE;

CREATE MATERIALIZED VIEW organizations AS (
    SELECT
        'us' AS region,
        id,
        CONCAT('us.lms.org.', public_id) AS public_id,
        name,
        created,
        updated,
        enabled
    FROM lms_us.organization

    UNION

    SELECT
        'ca' AS region,
        id,
        CONCAT('ca.lms.org.', public_id) AS public_id,
        name,
        created,
        updated,
        enabled
    FROM lms_ca.organization
) WITH NO DATA;
