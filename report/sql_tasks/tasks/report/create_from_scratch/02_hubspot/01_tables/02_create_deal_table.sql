DROP TABLE IF EXISTS hubspot.deals CASCADE;

CREATE TABLE hubspot.deals (
    id BIGINT PRIMARY KEY,
    name TEXT,
    services_start DATE,
    services_end DATE,
    amount FLOAT
);
