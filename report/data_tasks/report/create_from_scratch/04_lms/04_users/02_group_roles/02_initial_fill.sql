DROP INDEX IF EXISTS lms.group_roles_group_id_user_id_role_idx;

REFRESH MATERIALIZED VIEW lms.group_roles;

ANALYSE lms.group_roles;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX group_roles_group_id_user_id_role_idx ON lms.group_roles (group_id, user_id, role);
