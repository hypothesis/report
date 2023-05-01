DROP MATERIALIZED VIEW IF EXISTS lms.organization_roles CASCADE;

CREATE MATERIALIZED VIEW lms.organization_roles AS (
    WITH organization_roles AS (
        SELECT
            organization_id,
            role,
            user_id
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
    )

    SELECT
        -- We will include the organization and user names here even though we
        -- could get it from the tables directly to avoid issues in Metabase.
        -- It doesn't handle multiple columns with the same name (like `name`)
        -- properly.
        organizations.id AS organization_id,
        organizations.name AS organizations_name,
        organizations.public_id AS organization_public_id,
        role,
        users.id AS user_id,
        users.display_name AS user_display_name
    FROM organization_roles
    JOIN lms.organizations ON
        organizations.id = organization_roles.organization_id
    JOIN lms.users ON
        users.id = organization_roles.user_id
    ORDER BY organization_id, user_id
) WITH NO DATA;
