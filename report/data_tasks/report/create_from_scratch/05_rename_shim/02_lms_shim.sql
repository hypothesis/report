-- Create thin view shims to allow us to start moving reports in Metabase

DROP VIEW IF EXISTS lms.organizations;
CREATE VIEW lms.authorities AS (SELECT * FROM public.organizations);

DROP VIEW IF EXISTS lms.organization_activity;
CREATE VIEW lms.organization_activity AS (SELECT * FROM public.organization_activity);

DROP VIEW IF EXISTS lms.events;
CREATE VIEW lms.events AS (SELECT * FROM public.lms_events);
