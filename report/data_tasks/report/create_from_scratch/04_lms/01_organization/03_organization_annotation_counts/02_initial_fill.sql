DROP INDEX IF EXISTS lms.organization_annotation_counts_timescale_period_idx;
DROP INDEX IF EXISTS lms.organization_annotation_type_start_date_end_date_idx;

REFRESH MATERIALIZED VIEW lms.organization_annotation_counts;

ANALYSE lms.organization_annotation_counts;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_annotation_counts_timescale_period_idx
    ON lms.organization_annotation_counts (timescale, period, organization_id, role, sub_type, shared);
CREATE INDEX organization_annotation_counts_start_date_end_date_idx
    ON lms.organization_annotation_counts (start_date, end_date);
