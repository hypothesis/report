{% macro refresh_fdw_server(server_name, credentials, users) %}
    ALTER SERVER "{{server_name}}" OPTIONS(
        SET host '{{credentials.host}}', -- SECRET
        SET port '{{credentials.port}}',
        SET dbname '{{credentials.dbname}}'
    );


    {% for user in users %}
        ALTER USER MAPPING FOR "{{user}}" SERVER "{{server_name}}" OPTIONS(
            SET user '{{credentials.user}}',
            SET password '{{credentials.password}}' -- SECRET
        );
    {% endfor %}
{% endmacro %}

{{ refresh_fdw_server("h_us_server", fdw.h_us, users=[db_user, metabase_db_user]) }}
{{ refresh_fdw_server("h_ca_server", fdw.h_ca, users=[db_user, metabase_db_user]) }}
{{ refresh_fdw_server("lms_us_server", fdw.lms_us, users=[db_user, metabase_db_user]) }}
{{ refresh_fdw_server("lms_ca_server", fdw.lms_ca, users=[db_user, metabase_db_user]) }}
