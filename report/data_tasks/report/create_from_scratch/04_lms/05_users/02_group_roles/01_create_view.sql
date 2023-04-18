DROP MATERIALIZED VIEW IF EXISTS lms.group_roles CASCADE;

CREATE MATERIALIZED VIEW lms.group_roles AS (
    SELECT
        group_id,
        user_id,
        role
    FROM (
        SELECT
            CONCAT('us-', group_id) AS group_id,
            CONCAT('us-', user_id) AS user_id,
            role
        FROM lms_us.group_roles

        UNION ALL

        SELECT
            CONCAT('ca-', group_id) AS group_id,
            CONCAT('ca-', user_id) AS user_id,
            role
        FROM lms_ca.group_roles
    ) AS data
    ORDER BY group_id, user_id
) WITH NO DATA;
