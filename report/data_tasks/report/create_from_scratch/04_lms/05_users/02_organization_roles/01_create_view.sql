DROP MATERIALIZED VIEW IF EXISTS lms.organization_roles CASCADE;

CREATE MATERIALIZED VIEW lms.organization_roles AS (
    SELECT
        'us' AS region,
        CONCAT('us-', user_id) AS user_id,
        -- Include the non-concatenated id for simpler joining onto the
        -- `users_sensitive` table
        user_id AS remote_user_id,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('us-', organization_id)
        END AS organization_id,
        role
    FROM lms_us.organization_roles

    UNION ALL

    SELECT
        'ca' AS region,
        CONCAT('ca-', user_id) AS user_id,
        user_id AS remote_user_id,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('us-', organization_id)
        END AS organization_id,
        role
    FROM lms_ca.organization_roles
) WITH NO DATA;
