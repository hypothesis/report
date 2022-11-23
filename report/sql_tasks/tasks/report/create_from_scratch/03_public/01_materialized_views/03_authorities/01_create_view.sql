DROP MATERIALIZED VIEW IF EXISTS authority_activity CASCADE;

CREATE MATERIALIZED VIEW authority_activity AS (
    SELECT
        timescale, start_date, end_date, period,
        'us' AS region,
        authority_id,
        annotating_users, registering_users, total_users
    FROM h_us.authority_activity

    UNION ALL

    SELECT
        timescale, start_date, end_date, period,
        'ca' AS region,
        authority_id,
        annotating_users, registering_users, total_users
    FROM h_ca.authority_activity
) WITH NO DATA;
