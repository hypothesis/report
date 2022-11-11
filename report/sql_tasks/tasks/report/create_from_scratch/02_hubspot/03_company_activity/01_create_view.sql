DROP MATERIALIZED VIEW IF EXISTS hubspot.company_activity CASCADE;

CREATE MATERIALIZED VIEW hubspot.company_activity AS (
    WITH
        weeks AS (
            SELECT DATE_TRUNC('week', cohort_subscription_first_date)::DATE AS timestamp_week
            FROM hubspot.companies
            WHERE cohort_subscription_first_date IS NOT NULL

            UNION

            SELECT DATE_TRUNC('week', current_deal_services_end)::DATE AS timestamp_week
            FROM hubspot.companies
            WHERE current_deal_services_end IS NOT NULL
        ),

        timescales AS (
            SELECT column1 AS timescale FROM (
                VALUES ('week'), ('month'), ('semester'), ('academic_year'), ('all_time')
            ) AS data
        ),

        periods AS (
            SELECT
                timestamp_week,
                timescale::report.academic_timescale,
                report.multi_truncate(timescale, timestamp_week) AS period
            FROM weeks
            CROSS JOIN timescales
       )

    SELECT
        periods.timescale,
        periods.period AS calendar_date,
        report.present_date(timescale::text, period) AS period,
        companies.id AS company_id,
        True AS paying
    FROM hubspot.companies
    JOIN periods ON
        periods.timestamp_week >= companies.cohort_subscription_first_date
        AND periods.timestamp_week <= companies.current_deal_services_end
    WHERE
        cohort_subscription_first_date IS NOT NULL
        AND current_deal_services_end IS NOT NULL
    GROUP BY period, timescale, company_id
    ORDER BY period, timescale, company_id
) WITH NO DATA;