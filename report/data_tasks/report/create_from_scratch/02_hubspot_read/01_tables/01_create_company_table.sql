DROP TABLE IF EXISTS hubspot.companies_raw CASCADE;

CREATE TABLE hubspot.companies_raw (
   -- General
    id BIGINT PRIMARY KEY,
    name TEXT,
    lms_organization_id TEXT,
    life_cycle_stage TEXT,
    -- Owners
    company_owner_id INT,
    success_owner_id INT,
    -- Cohort
    cohort_pilot_first_date DATE,
    cohort_subscription_first_date DATE,
    -- Deals
    current_deal_services_start DATE,
    current_deal_services_end DATE,
    current_deal_amount FLOAT,
    current_deal_users_contracted INT,
    deals_last_update DATE
);

CREATE INDEX companies_lms_organization_id_idx ON hubspot.companies_raw (lms_organization_id);

-- If we were using Postgres 12+ we could use a calculated column. This is the
-- next best thing where we have a view with a calculated column. I'm hoping we
-- can get away without materializing this.
DROP VIEW IF EXISTS hubspot.companies CASCADE;

CREATE VIEW hubspot.companies AS (
    SELECT
        *,
        CASE
            WHEN
                current_deal_services_start IS NOT NULL
                AND current_deal_services_start <= NOW()
                AND current_deal_services_end IS NOT NULL
                AND current_deal_services_end >= NOW()
            THEN True
            ELSE False
        END AS in_deal
    FROM hubspot.companies_raw
);
