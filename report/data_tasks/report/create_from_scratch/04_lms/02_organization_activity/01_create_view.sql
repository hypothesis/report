DROP MATERIALIZED VIEW IF EXISTS lms.organization_activity CASCADE;

CREATE MATERIALIZED VIEW lms.organization_activity AS (
    WITH
        raw_organization_activity AS (
            SELECT
                timescale,
                start_date,
                end_date,
                period,
                role,
                CONCAT('us-', organization_id) AS organization_id,
                annotation_count,
                active,
                billable,
                launch_count
            FROM lms_us.organization_activity

            UNION ALL

            SELECT
                timescale,
                start_date,
                end_date,
                period,
                role,
                CONCAT('ca-', organization_id) AS organization_id,
                annotation_count,
                active,
                billable,
                launch_count
            FROM lms_ca.organization_activity
        )

    SELECT
        -- Time based elements
        raw_organization_activity.timescale,
        raw_organization_activity.start_date,
        raw_organization_activity.end_date,
        raw_organization_activity.period,
        -- Facets
        raw_organization_activity.role,
        COALESCE(paying, FALSE)::BOOLEAN AS paying,
        raw_organization_activity.organization_id,
        -- Metrics
        raw_organization_activity.annotation_count,
        raw_organization_activity.active,
        raw_organization_activity.billable,
        raw_organization_activity.launch_count
    FROM raw_organization_activity
    LEFT OUTER JOIN LATERAL (
        SELECT
            TRUE AS paying
        FROM hubspot.deals
        JOIN hubspot.company_deals ON
            company_deals.deal_id = deals.id
        JOIN hubspot.companies ON
            companies.id = company_deals.company_id
        JOIN lms.organizations ON
            organizations.public_id = companies.lms_organization_id
        WHERE
            organizations.id = organization_id
            -- Check for overlapping date ranges
            AND DATERANGE(deals.services_start, deals.services_end, '[)') && DATERANGE(start_date, end_date, '[)')
            AND deals.amount > 0
        LIMIT 1
    ) AS paying ON TRUE
) WITH NO DATA;
