DROP MATERIALIZED VIEW IF EXISTS lms.organization_assignments CASCADE;

CREATE MATERIALIZED VIEW lms.organization_assignments AS (
    SELECT
        CONCAT('us-', organization_id) AS organization_id,
        CONCAT('us-', assignment_id) AS assignment_id
    FROM lms_us.organization_assignments

    UNION ALL

    SELECT
        CONCAT('ca-', organization_id) AS organization_id,
        CONCAT('ca-', assignment_id) AS assignment_id
    FROM lms_ca.organization_assignments
) WITH NO DATA;
