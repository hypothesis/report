DROP TABLE IF EXISTS hubspot.owners CASCADE;

CREATE TABLE hubspot.owners (
    id BIGINT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    name TEXT,
    email TEXT,
    archived BOOLEAN
);
