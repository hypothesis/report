DROP MATERIALIZED VIEW IF EXISTS lms.organization_assignment_types CASCADE;

CREATE MATERIALIZED VIEW lms.organization_assignment_types AS (
    WITH aggregates AS (
        SELECT
            organization_assignments.organization_id,
            assignments.file_type,
            COUNT(1) AS count
        FROM lms.organization_assignments
        JOIN lms.assignments ON
            assignments.id = organization_assignments.assignment_id
        GROUP BY
            organization_assignments.organization_id,
            assignments.file_type
    )

    SELECT
        aggregates.*,
        -- Include the public id as it's very convenient to filter by
        organizations.public_id
    FROM aggregates
    JOIN lms.organizations ON
        organizations.id = aggregates.organization_id
    ORDER BY
        aggregates.organization_id,
        count DESC
) WITH NO DATA;
