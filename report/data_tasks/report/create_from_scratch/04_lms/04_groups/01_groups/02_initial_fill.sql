DROP INDEX IF EXISTS lms.groups_id_idx;
DROP INDEX IF EXISTS lms.groups_created_group_type_idx;

REFRESH MATERIALIZED VIEW lms.groups;

ANALYSE lms.groups;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX groups_id_idx ON lms.groups (id);
CREATE INDEX groups_created_group_type_idx ON lms.groups (created, group_type);
