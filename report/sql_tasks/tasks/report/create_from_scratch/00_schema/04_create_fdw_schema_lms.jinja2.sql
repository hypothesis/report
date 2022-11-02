DROP SCHEMA IF EXISTS lms_us CASCADE;
DROP SCHEMA IF EXISTS lms_ca CASCADE;

CREATE SCHEMA lms_us AUTHORIZATION "{{db_user}}";
CREATE SCHEMA lms_ca AUTHORIZATION "{{db_user}}";

-- Create types required for imports

DROP TYPE IF EXISTS report.roles CASCADE;
CREATE TYPE report.roles AS ENUM (
    'teacher', 'user'
);

DROP TYPE IF EXISTS report.event_type CASCADE;
CREATE TYPE report.event_type AS ENUM (
    'configured_launch', 'deep_linking'
);

DROP TYPE IF EXISTS report.academic_timescale CASCADE;
CREATE TYPE report.academic_timescale AS ENUM (
    'week', 'month', 'semester', 'academic_year', 'all_time'
);

-- Import required tables

IMPORT FOREIGN SCHEMA "public" LIMIT TO (
    organization
) FROM SERVER "lms_us_server" INTO lms_us;

IMPORT FOREIGN SCHEMA "public" LIMIT TO (
    organization
) FROM SERVER "lms_ca_server" INTO lms_ca;

IMPORT FOREIGN SCHEMA "report" LIMIT TO (
    organization_activity
) FROM SERVER "lms_us_server" INTO lms_us;

IMPORT FOREIGN SCHEMA "report" LIMIT TO (
    organization_activity
) FROM SERVER "lms_ca_server" INTO lms_ca;
