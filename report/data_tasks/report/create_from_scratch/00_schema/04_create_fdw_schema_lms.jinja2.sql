-- Create types required for imports

DROP TYPE IF EXISTS report.roles CASCADE;
CREATE TYPE report.roles AS ENUM (
    'teacher', 'user'
);

DROP TYPE IF EXISTS report.event_type CASCADE;
CREATE TYPE report.event_type AS ENUM (
    'configured_launch', 'deep_linking', 'audit'
);

DROP TYPE IF EXISTS report.academic_timescale CASCADE;
CREATE TYPE report.academic_timescale AS ENUM (
    'week', 'month', 'semester', 'academic_year', 'trailing_year', 'all_time'
);

-- Import required tables

{% macro import_lms(server_name, schema_name) %}
    DROP SCHEMA IF EXISTS {{schema_name}} CASCADE;

    CREATE SCHEMA {{schema_name}} AUTHORIZATION "{{db_user}}";

    IMPORT FOREIGN SCHEMA "public" LIMIT TO (
        organization
    ) FROM SERVER "{{server_name}}" INTO {{schema_name}};

    IMPORT FOREIGN SCHEMA "report" LIMIT TO (
        events,
        groups,
        group_bubbled_activity,
        group_bubbled_counts,
        group_map,
        group_roles,
        organization,
        organization_activity,
        organization_roles,
        users_sensitive
    ) FROM SERVER "{{server_name}}" INTO {{schema_name}};
{% endmacro %}

{{ import_lms("lms_us_server", "lms_us") }}
{{ import_lms("lms_ca_server", "lms_ca") }}
