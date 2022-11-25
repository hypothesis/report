-- This schema largely exists to dump enums/types into so we can import from
-- the report schemas in LMS and H without trouble
DROP SCHEMA IF EXISTS report CASCADE;
CREATE SCHEMA report AUTHORIZATION "{{db_user}}";

DROP SCHEMA IF EXISTS hubspot CASCADE;
CREATE SCHEMA hubspot AUTHORIZATION "{{db_user}}";