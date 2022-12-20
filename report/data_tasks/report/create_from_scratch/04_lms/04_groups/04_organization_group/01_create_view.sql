DROP MATERIALIZED VIEW IF EXISTS lms.organization_group CASCADE;

CREATE MATERIALIZED VIEW lms.organization_group AS (
    -- Use distinct here to simplify the model from LMS. We want one row per
    -- org, rather than each org / lms-group combo
    SELECT DISTINCT group_id, organization_id
    FROM lms.group_map
) WITH NO DATA;
