-- In production this must have been either
-- provisioned while creating the RDS db or run with and admin user
-- before this task can run successfully
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

{% macro create_fdw_server(server_name, credentials, users) %}
    DROP SERVER IF EXISTS "{{server_name}}" CASCADE;

    CREATE SERVER "{{server_name}}" FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (
            host '{{credentials.host}}',  -- SECRET
            port '{{credentials.port}}',
            dbname '{{credentials.dbname}}'
        );

    {% for user in users %}
        DROP USER MAPPING IF EXISTS FOR "{{user}}" SERVER "{{server_name}}";

        CREATE USER MAPPING IF NOT EXISTS FOR "{{user}}"
            SERVER "{{server_name}}"
            OPTIONS (
                user '{{credentials.user}}',
                password '{{credentials.password}}' -- SECRET
            );
    {% endfor %}
{% endmacro %}

{{ create_fdw_server("h_us_server", fdw.h_us, users=[db_user, metabase_db_user]) }}
{{ create_fdw_server("h_ca_server", fdw.h_ca, users=[db_user, metabase_db_user]) }}
{{ create_fdw_server("lms_us_server", fdw.lms_us, users=[db_user, metabase_db_user]) }}
{{ create_fdw_server("lms_ca_server", fdw.lms_ca, users=[db_user, metabase_db_user]) }}
