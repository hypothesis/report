DROP TABLE IF EXISTS hubspot.deals CASCADE;

CREATE TABLE hubspot.deals (
    id BIGINT PRIMARY KEY,
    company_id BIGINT,
    services_start DATE,
    services_end DATE,
    amount FLOAT
);

CREATE INDEX deals_company_id_idx ON hubspot.deals (company_id);
