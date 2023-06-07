DROP INDEX IF EXISTS lms.organization_assignment_types_organization_id_file_type_idx;

REFRESH MATERIALIZED VIEW lms.organization_assignment_types;

ANALYSE lms.organization_assignment_types;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_assignment_types_organization_id_file_type_idx ON lms.organization_assignment_types (organization_id, file_type);
