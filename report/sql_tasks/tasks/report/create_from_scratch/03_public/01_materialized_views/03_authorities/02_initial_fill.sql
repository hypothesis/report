DROP INDEX IF EXISTS authorities_id_idx;

REFRESH MATERIALIZED VIEW authorities;

ANALYSE authorities;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX authorities_id_idx ON authorities (id);