DROP TABLE IF EXISTS hubspot.companies CASCADE;

CREATE TABLE hubspot.companies (
   -- General
    id BIGINT PRIMARY KEY,
    name TEXT,
    organization_public_id TEXT,
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

CREATE INDEX companies_organization_public_id_idx ON hubspot.companies (organization_public_id);
