DROP INDEX IF EXISTS lms.users_id_idx;

REFRESH MATERIALIZED VIEW lms.users;

ANALYSE lms.users;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX users_id_idx ON lms.users (id);
