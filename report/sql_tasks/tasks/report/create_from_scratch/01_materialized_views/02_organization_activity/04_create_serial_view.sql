DROP TYPE IF EXISTS report.activity_metric CASCADE;

CREATE TYPE report.activity_metric AS ENUM (
    'annotation', 'billable', 'active'
);

-- A full serial view of the activity counts where each type of count
-- for teachers and users and metric is selectable from a single column. This
-- allows for more easy switching between metrics using a drop down.
CREATE VIEW organization_activity_serial AS (
    SELECT
        timescale,
        timestamp,
        period,
        role,
        'annotation'::report.activity_metric AS metric,
        organization_id,
        annotation_count AS count,
        annotation_count_growth AS growth
    FROM organization_activity
    -- We don't yet track teacher annotation counts
    WHERE role = 'user'

    UNION ALL

    SELECT
        timescale,
        timestamp,
        period,
        role,
        'active'::report.activity_metric AS metric,
        organization_id,
        active AS count,
        active_growth AS growth
    FROM organization_activity

    UNION ALL

    SELECT
        timescale,
        timestamp,
        period,
        role,
        'billable'::report.activity_metric AS metric,
        organization_id,
        billable AS count,
        billable_growth AS growth
    FROM organization_activity
);