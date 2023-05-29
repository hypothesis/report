DROP TABLE IF EXISTS hubspot.contacts CASCADE;

CREATE TABLE hubspot.contacts (
    id BIGINT PRIMARY KEY,
    email TEXT
);

CREATE UNIQUE INDEX contacts_email_idx ON hubspot.contacts (email);
