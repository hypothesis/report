DROP VIEW IF EXISTS hubspot.company_property_update CASCADE;

-- This view recreates the properties that we update on Hubspot companies
CREATE VIEW hubspot.company_property_update AS (
    WITH
        -- All of the metrics we want for now can be expressed as a name, role,
        -- timescale and an offset, where an offset of 0 means the latest
        -- period, and 1 means the one before etc.
        metric_definitions AS (
            SELECT
                column1 AS metric_name,
                column2 AS role,
                column3 AS timescale,
                column4 AS offset
            FROM (
                VALUES
                    ('lms_teachers_last_semester', 'teacher', 'semester', 1),
                    ('lms_teachers_this_semester', 'teacher', 'semester', 0),
                    ('lms_users_last_academic_year', 'user', 'academic_year', 1),
                    ('lms_users_this_academic_year', 'user', 'academic_year', 0),
                    ('lms_users_last_semester', 'user', 'semester', 1),
                    ('lms_users_this_semester', 'user', 'semester', 0),
                    ('lms_users_all_time', 'user', 'all_time', 0)
            ) AS data
        ),

        -- Tack on the correct period by consuming the timescale and offset
        -- from the above metric definitions
        metrics AS (
            SELECT
                metric_definitions.*,
                metric_period.period
            FROM metric_definitions
            -- Get the correct time period to join on to
            LEFT JOIN LATERAL (
                SELECT DISTINCT(period)
                FROM lms.organization_activity
                WHERE timescale::text = metric_definitions.timescale
                ORDER BY period DESC
                LIMIT 1
                OFFSET metric_definitions.offset
            ) metric_period ON TRUE
        ),

        -- Join these with the organization activity to get the actual values
        -- in rows one metric per row with metric name as a value
        values_in_rows AS (
            SELECT
                organization_activity.organization_id,
                metrics.metric_name,
                organization_activity.billable as count
            FROM metrics
            LEFT OUTER JOIN lms.organization_activity ON
                organization_activity.timescale::text = metrics.timescale
                AND organization_activity.role::text = metrics.role
                AND organization_activity.period = metrics.period
        )

    -- Finally we fan out the values as columns for insertion into Hubspot
    SELECT
        -- This must be called `hs_object_id` and is specified by the Hubspot
        -- API as the object key
        companies.id AS hs_object_id,
        -- All of these values are defined by us
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_teachers_last_semester'), 0) AS lms_teachers_last_semester,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_teachers_this_semester'), 0) AS lms_teachers_this_semester,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_users_last_academic_year'), 0) AS lms_users_last_academic_year,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_users_this_academic_year'), 0) AS lms_users_this_academic_year,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_users_last_semester'), 0) AS lms_users_last_semester,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_users_this_semester'), 0) AS lms_users_this_semester,
        COALESCE(MAX(count) FILTER (WHERE metric_name='lms_users_all_time'), 0) AS lms_users_all_time
    FROM values_in_rows
    JOIN lms.organizations ON
        organization_id = organizations.id
    JOIN hubspot.companies ON
        companies.lms_organization_id = organizations.public_id
    GROUP BY companies.id
);
