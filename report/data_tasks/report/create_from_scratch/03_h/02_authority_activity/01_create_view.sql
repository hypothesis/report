DROP MATERIALIZED VIEW IF EXISTS h.authority_activity CASCADE;

CREATE MATERIALIZED VIEW h.authority_activity AS (
    SELECT
        timescale, start_date, end_date, period,
        'us' AS region,
        authority_id,
        annotating_users, registering_users, total_users,
        shared_annotations, reply_annotations, annotations
    FROM h_us.authority_activity

    UNION ALL

    SELECT
        timescale, start_date, end_date, period,
        'ca' AS region,
        authority_id,
        annotating_users, registering_users, total_users,
        shared_annotations, reply_annotations, annotations
    FROM h_ca.authority_activity
) WITH NO DATA;
