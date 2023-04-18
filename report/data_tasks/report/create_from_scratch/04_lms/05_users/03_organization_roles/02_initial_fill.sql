DROP INDEX IF EXISTS lms.organization_roles_group_id_user_id_role_idx;

REFRESH MATERIALIZED VIEW lms.organization_roles;

ANALYSE lms.organization_roles;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_roles_group_id_user_id_role_idx ON lms.organization_roles (organization_id, user_id, role);
