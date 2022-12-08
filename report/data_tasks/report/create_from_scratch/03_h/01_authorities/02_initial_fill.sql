DROP INDEX IF EXISTS h.authorities_id_idx;

REFRESH MATERIALIZED VIEW h.authorities;

ANALYSE h.authorities;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX authorities_id_idx ON h.authorities (id);
