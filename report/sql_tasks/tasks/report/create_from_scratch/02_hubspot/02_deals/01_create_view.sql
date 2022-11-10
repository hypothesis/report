-- For the moment we are going to fake deal information based on company
-- properties, but we will eventually read the real data from Hubspot. This
-- allows us to do this in chunks

DROP MATERIALIZED VIEW IF EXISTS hubspot.deals CASCADE;

CREATE MATERIALIZED VIEW hubspot.deals AS (
    SELECT
        id::BIGINT AS company_id,
        cohort_subscription_first_date::DATE AS services_start,
        current_deal_services_end::DATE AS services_end,
        current_deal_amount::FLOAT AS amount
    FROM hubspot.companies
    ORDER BY cohort_subscription_first_date
) WITH NO DATA;