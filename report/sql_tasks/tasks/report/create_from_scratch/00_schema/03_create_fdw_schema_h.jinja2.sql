-- Create types required for imports

DROP TYPE IF EXISTS report.timescale CASCADE;

CREATE TYPE report.timescale AS ENUM (
    'week', 'month', 'semester', 'academic_year', 'year', 'all_time'
);

{% macro import_h(server_name, schema_name) %}
    DROP SCHEMA IF EXISTS {{schema_name}} CASCADE;

    CREATE SCHEMA {{schema_name}} AUTHORIZATION "{{db_user}}";

    IMPORT FOREIGN SCHEMA "report" LIMIT TO (
        authorities,
        authority_activity
    ) FROM SERVER "{{server_name}}" INTO {{schema_name}};
{% endmacro %}

{{ import_h("h_us_server", "h_us") }}
{{ import_h("h_ca_server", "h_ca") }}
