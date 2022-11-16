DROP INDEX IF EXISTS organizations_id_idx;
DROP INDEX IF EXISTS organizations_public_id_idx;

REFRESH MATERIALIZED VIEW organizations;

ANALYSE organizations;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organizations_id_idx ON organizations (id);
CREATE UNIQUE INDEX organizations_public_id_idx ON organizations (public_id);