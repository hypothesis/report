DROP TABLE IF EXISTS hubspot.company_deals CASCADE;

CREATE TABLE hubspot.company_deals (
    company_id BIGINT NOT NULL,
    deal_id BIGINT NOT NULL
);

CREATE UNIQUE INDEX company_deals_company_id_deal_id_idx ON hubspot.company_deals (company_id, deal_id);