-- In production this must have been either 
-- provisioned while creating the RDS db or run with and admin user
-- before this task can run successfully
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS "h_us_server" CASCADE;
CREATE SERVER "h_us_server" FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '{{fdw.h_us.host}}', port '{{fdw.h_us.port}}', dbname '{{fdw.h_us.dbname}}');

DROP SERVER IF EXISTS "lms_us_server" CASCADE;
CREATE SERVER "lms_us_server" FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '{{fdw.lms_us.host}}', port '{{fdw.lms_us.port}}', dbname '{{fdw.lms_us.dbname}}');

DROP USER MAPPING IF EXISTS FOR "{{db_user}}" SERVER "h_us_server";
CREATE USER MAPPING IF NOT EXISTS FOR "{{db_user}}"
    SERVER "h_us_server"
    OPTIONS (
        user '{{fdw.h_us.user}}',
        password '{{fdw.h_us.password}}' -- SECRET
    );

DROP USER MAPPING IF EXISTS FOR "{{db_user}}" SERVER "lms_us_server";
CREATE USER MAPPING IF NOT EXISTS FOR "{{db_user}}"
    SERVER "lms_us_server"
    OPTIONS (
        user '{{fdw.lms_us.user}}',
        password '{{fdw.lms_us.password}}' -- SECRET
    );