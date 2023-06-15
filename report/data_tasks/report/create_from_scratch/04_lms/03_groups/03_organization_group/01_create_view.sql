DROP MATERIALIZED VIEW IF EXISTS lms.organization_group CASCADE;

CREATE MATERIALIZED VIEW lms.organization_group AS (
    -- Use distinct here to simplify the model from LMS. We want one row per
    -- org, rather than each org / lms-group combo
    WITH organization_group AS (
        SELECT DISTINCT group_id, organization_id
        FROM (
            SELECT
            CONCAT('us-', group_id) AS group_id,
            CASE
                WHEN organization_id IS NULL THEN NULL
                ELSE CONCAT('us-', organization_id)
            END AS organization_id
        FROM
            lms_us.group_map

        UNION ALL

        SELECT
            CONCAT('ca-', group_id) AS group_id,
            CASE
                WHEN organization_id IS NULL THEN NULL
                ELSE CONCAT('ca-', organization_id)
            END AS organization_id
        FROM
            lms_ca.group_map
        ) AS data
    )

    SELECT
        -- We will include the group and organization names here even though
        -- we could get it from the tables directly to avoid issues in Metabase.
        -- It doesn't handle multiple columns with the same name (like `name`)
        -- properly.
        organizations.id AS organization_id,
        organizations.name AS organization_name,
        organizations.public_id AS organization_public_id,
        groups.id AS group_id,
        groups.name AS group_name
    FROM organization_group
    JOIN lms.organizations ON
        organizations.id = organization_group.organization_id
    JOIN lms.groups ON
        groups.id = organization_group.group_id
    ORDER BY organization_id, group_id
) WITH NO DATA;
