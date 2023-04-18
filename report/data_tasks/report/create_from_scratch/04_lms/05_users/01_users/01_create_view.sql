DROP MATERIALIZED VIEW IF EXISTS lms.users CASCADE;

CREATE MATERIALIZED VIEW lms.users AS (
    SELECT *
    FROM (
        SELECT
            CONCAT('us-', id) AS id,
            display_name,
            email,
            username,
            is_teacher,
            registered_date
        FROM lms_us.users

        UNION ALL

        SELECT
            CONCAT('ca-', id) AS id,
            display_name,
            email,
            username,
            is_teacher,
            registered_date
        FROM lms_ca.users
    ) AS data
    ORDER BY id

) WITH NO DATA;
