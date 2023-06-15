DROP INDEX IF EXISTS lms.assignments_organization_id_assignment_id_idx;

REFRESH MATERIALIZED VIEW lms.organization_assignments;

ANALYSE lms.organization_assignments;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX assignments_organization_id_assignment_id_idx ON lms.organization_assignments (organization_id, assignment_id);
