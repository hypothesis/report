DROP INDEX IF EXISTS lms.user_annotation_counts_group_id_sub_type_shared_idx;

REFRESH MATERIALIZED VIEW lms.user_annotation_counts;

ANALYSE lms.user_annotation_counts;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX user_annotation_counts_group_id_sub_type_shared_idx
    ON lms.user_annotation_counts (user_id, group_id, sub_type, shared, created_week);
