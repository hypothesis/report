-- This schema largely exists to dump enums/types into so we can import from
-- the report schemas in LMS and H without trouble
DROP SCHEMA IF EXISTS report CASCADE;
CREATE SCHEMA report AUTHORIZATION "{{db_user}}";

-- Schema for storing data from Hubspot
DROP SCHEMA IF EXISTS hubspot CASCADE;
CREATE SCHEMA hubspot AUTHORIZATION "{{db_user}}";

-- Schema for views and reports across all H instances
DROP SCHEMA IF EXISTS h CASCADE;
CREATE SCHEMA h AUTHORIZATION "{{db_user}}";

-- Schema for views and reports across all LMS instances
DROP SCHEMA IF EXISTS lms CASCADE;
CREATE SCHEMA lms AUTHORIZATION "{{db_user}}";
