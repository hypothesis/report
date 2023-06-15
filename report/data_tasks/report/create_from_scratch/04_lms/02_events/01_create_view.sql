DROP MATERIALIZED VIEW IF EXISTS lms.events CASCADE;

CREATE MATERIALIZED VIEW lms.events AS (
    -- These rows have a lot of elements with missing users and organizations
    -- We could merge these together, but by adding a region we can use a
    -- simpler UNION ALL without having to combine these rows. This also
    -- preserves more information.
    SELECT
        timestamp_week,
        'us' AS region,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('us-', organization_id)
        END AS organization_id,
        event_type,
        CASE
            WHEN user_id IS NULL THEN NULL
            ELSE CONCAT('us-', user_id)
        END AS user_id,
        event_count
    FROM lms_us.events

    UNION ALL

    SELECT
        timestamp_week,
        'ca' AS region,
        CASE
            WHEN organization_id IS NULL THEN NULL
            ELSE CONCAT('ca-', organization_id)
        END AS organization_id,
        event_type,
        CASE
            WHEN user_id IS NULL THEN NULL
            ELSE CONCAT('ca-', user_id)
        END AS user_id,
        event_count
    FROM lms_ca.events
) WITH NO DATA;
