DROP INDEX IF EXISTS lms.organization_group_organization_id_group_id_idx;

REFRESH MATERIALIZED VIEW lms.organization_group;

ANALYSE lms.organization_group;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_group_organization_id_group_id_idx ON lms.organization_group (organization_id, group_id);
