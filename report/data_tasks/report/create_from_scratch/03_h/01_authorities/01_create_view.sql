DROP MATERIALIZED VIEW IF EXISTS h.authorities CASCADE;

CREATE MATERIALIZED VIEW h.authorities AS (
    -- This looks foolish, but if we create this directly from H (US) in
    -- Metabase won't let us do a join...
    SELECT * FROM h_us.authorities
) WITH NO DATA;
