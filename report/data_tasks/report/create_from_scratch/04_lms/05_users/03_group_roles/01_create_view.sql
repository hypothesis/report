DROP MATERIALIZED VIEW IF EXISTS lms.group_roles CASCADE;

CREATE MATERIALIZED VIEW lms.group_roles AS (
    SELECT
        'us' AS region,
        CONCAT('us-', user_id) AS user_id,
        -- Include the non-concatenated id for simpler joining onto the
        -- `users_sensitive` table
        user_id AS remote_user_id,
        CONCAT('us-', group_id) AS group_id,
        role
    FROM lms_us.group_roles

    UNION ALL

    SELECT
        'ca' AS region,
        CONCAT('ca-', user_id) AS user_id,
        user_id AS remote_user_id,
        CONCAT('ca-', group_id) AS group_id,
        role
    FROM lms_ca.group_roles
) WITH NO DATA;
