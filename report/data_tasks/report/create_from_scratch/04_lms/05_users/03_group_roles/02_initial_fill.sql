DROP INDEX IF EXISTS lms.group_roles_user_id_group_id_role_idx;

REFRESH MATERIALIZED VIEW lms.group_roles;

ANALYSE lms.group_roles;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX group_roles_user_id_group_id_role_idx ON lms.group_roles (user_id, group_id, role);
