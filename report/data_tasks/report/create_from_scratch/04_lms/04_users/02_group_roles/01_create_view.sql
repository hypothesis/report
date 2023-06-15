DROP MATERIALIZED VIEW IF EXISTS lms.group_roles CASCADE;

CREATE MATERIALIZED VIEW lms.group_roles AS (
    WITH group_roles AS (
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
    )

    SELECT
        -- We will include the group and user names here even though we could
        -- get it from the tables directly to avoid issues in Metabase.
        -- It doesn't handle multiple columns with the same name (like `name`)
        -- properly.
        groups.id AS group_id,
        groups.name AS group_name,
        role,
        users.id AS user_id,
        users.display_name AS user_display_name
    FROM group_roles
    JOIN lms.groups ON
        groups.id = group_roles.group_id
    JOIN lms.users ON
        users.id = group_roles.user_id
    ORDER BY group_id, user_id
) WITH NO DATA;
