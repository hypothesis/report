DROP MATERIALIZED VIEW IF EXISTS lms.organization_group CASCADE;

CREATE MATERIALIZED VIEW lms.organization_group AS (
    -- Use distinct here to simplify the model from LMS. We want one row per
    -- org, rather than each org / lms-group combo
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
) WITH NO DATA;
