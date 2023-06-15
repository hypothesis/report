DROP INDEX IF EXISTS lms.organization_annotation_types_timescale_period_idx;
DROP INDEX IF EXISTS lms.organization_annotation_type_start_date_end_date_idx;

REFRESH MATERIALIZED VIEW lms.organization_annotation_types;

ANALYSE lms.organization_annotation_types;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX organization_annotation_types_timescale_period_idx
    ON lms.organization_annotation_types (timescale, period, organization_id, sub_type, shared);
CREATE INDEX organization_annotation_types_start_date_end_date_idx
    ON lms.organization_annotation_types (start_date, end_date);
