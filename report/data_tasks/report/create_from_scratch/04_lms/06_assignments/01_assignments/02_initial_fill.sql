DROP INDEX IF EXISTS lms.assignments_id_idx;

REFRESH MATERIALIZED VIEW lms.assignments;

ANALYSE lms.assignments;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX assignments_id_idx ON lms.assignments (id);
