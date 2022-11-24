DROP MATERIALIZED VIEW IF EXISTS lms_events CASCADE;

CREATE MATERIALIZED VIEW lms_events AS (
    -- These rows have a lot of elements with missing users and organizations
    -- We could merge these together, but by adding a region we can use a
    -- simpler UNION ALL without having to combine these rows. This also
    -- preserves more information.
    SELECT
        timestamp_week,
        'us' AS region,
        CONCAT('us-', organization_id) AS organization_id,
        event_type,
        CONCAT('us-', user_id) AS user_id,
        event_count
    FROM lms_us.events

    UNION ALL

    SELECT
        timestamp_week,
        'ca' AS region,
        CONCAT('ca-', organization_id) AS organization_id,
        event_type,
        CONCAT('ca-', user_id) AS user_id,
        event_count
    FROM lms_ca.events
) WITH NO DATA;
