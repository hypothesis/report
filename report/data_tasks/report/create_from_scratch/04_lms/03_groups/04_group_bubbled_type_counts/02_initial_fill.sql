DROP INDEX IF EXISTS lms.group_bubbled_type_counts_group_id_sub_type_shared_idx;

REFRESH MATERIALIZED VIEW lms.group_bubbled_type_counts;

ANALYSE lms.group_bubbled_type_counts;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX group_bubbled_type_counts_group_id_sub_type_shared_idx
    ON lms.group_bubbled_type_counts (group_id, sub_type, shared, created_week);
