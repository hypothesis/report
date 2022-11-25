DROP MATERIALIZED VIEW IF EXISTS authorities CASCADE;

CREATE MATERIALIZED VIEW authorities AS (
    -- This looks foolish, but if we create this directly from H (US) in
    -- Metabase won't let us do a join...
    SELECT * FROM h_us.authorities
) WITH NO DATA;
