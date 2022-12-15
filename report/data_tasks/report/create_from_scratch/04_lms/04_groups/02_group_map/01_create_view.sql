DROP MATERIALIZED VIEW IF EXISTS lms.group_map CASCADE;

CREATE MATERIALIZED VIEW lms.group_map AS (
    SELECT
        CONCAT('us-', group_id) AS group_id,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('us-', organization_id)
        END AS organization_id,
        CASE
            WHEN lms_grouping_id IS NULL THEN NULL
            ELSE CONCAT('us-', lms_grouping_id)
        END AS lms_grouping_id
    FROM
        lms_us.group_map

    UNION ALL

    SELECT
        CONCAT('ca-', group_id) AS group_id,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('ca-', organization_id)
        END AS organization_id,
        CASE
            WHEN lms_grouping_id IS NULL THEN NULL
            ELSE CONCAT('ca-', lms_grouping_id)
        END AS lms_grouping_id
    FROM
        lms_ca.group_map
) WITH NO DATA;
