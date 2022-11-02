{% macro import_h(server_name, schema_name) %}
    DROP SCHEMA IF EXISTS {{schema_name}} CASCADE;

    CREATE SCHEMA {{schema_name}} AUTHORIZATION "{{db_user}}";
{% endmacro %}

{{ import_h("h_us_server", "h_us") }}
{{ import_h("h_ca_server", "h_ca") }}
