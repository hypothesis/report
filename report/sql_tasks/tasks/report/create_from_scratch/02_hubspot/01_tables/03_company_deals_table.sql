DROP TABLE IF EXISTS hubspot.company_deals CASCADE;

CREATE TABLE hubspot.company_deals (
    company_id BIGINT NOT NULL,
    deal_id BIGINT NOT NULL
);
