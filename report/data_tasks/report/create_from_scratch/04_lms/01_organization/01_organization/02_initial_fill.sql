DROP INDEX IF EXISTS lms.organizations_id_idx;
DROP INDEX IF EXISTS lms.organizations_public_id_idx;

REFRESH MATERIALIZED VIEW lms.organizations;

ANALYSE lms.organizations;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organizations_id_idx ON lms.organizations (id);
CREATE UNIQUE INDEX organizations_public_id_idx ON lms.organizations (public_id);
