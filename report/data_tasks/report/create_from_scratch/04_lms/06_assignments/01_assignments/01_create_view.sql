DROP MATERIALIZED VIEW IF EXISTS lms.assignments CASCADE;

CREATE MATERIALIZED VIEW lms.assignments AS (
    SELECT
        CONCAT('us-', id) AS id,
        url,
        file_type,
        created,
        updated
    FROM lms_us.assignments

    UNION ALL

    SELECT
        CONCAT('ca-', id) AS id,
        url,
        file_type,
        created,
        updated
    FROM lms_ca.assignments
) WITH NO DATA;
