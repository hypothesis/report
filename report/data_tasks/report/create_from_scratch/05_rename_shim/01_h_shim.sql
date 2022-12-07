-- Create thin view shims to allow us to start moving reports in Metabase

DROP VIEW IF EXISTS h.authorities;
CREATE VIEW h.authorities AS (SELECT * FROM public.authorities);

DROP VIEW IF EXISTS h.authority_activity;
CREATE VIEW h.authority_activity AS (SELECT * FROM public.authority_activity);
