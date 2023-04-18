DROP MATERIALIZED VIEW IF EXISTS lms.organization_roles CASCADE;

CREATE MATERIALIZED VIEW lms.organization_roles AS (
    SELECT
        organization_id,
        user_id,
        role
    FROM (
        SELECT
            CONCAT('us-', organization_id) AS organization_id,
            CONCAT('us-', user_id) AS user_id,
            role
        FROM lms_us.organization_roles

        UNION ALL

        SELECT
            CONCAT('ca-', organization_id) AS organization_id,
            CONCAT('ca-', user_id) AS user_id,
            role
        FROM lms_ca.organization_roles
    ) AS data
    ORDER BY organization_id, user_id
) WITH NO DATA;
