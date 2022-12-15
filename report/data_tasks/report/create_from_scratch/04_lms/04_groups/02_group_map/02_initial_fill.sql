DROP INDEX IF EXISTS lms.group_map_group_id_lms_grouping_id_idx;
DROP INDEX IF EXISTS lms.group_map_organization_id_idx;

REFRESH MATERIALIZED VIEW lms.group_map;

ANALYSE lms.group_map;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX group_map_group_id_lms_grouping_id_idx ON lms.group_map (group_id, lms_grouping_id);
CREATE INDEX group_map_organization_id_idx ON lms.group_map (organization_id);