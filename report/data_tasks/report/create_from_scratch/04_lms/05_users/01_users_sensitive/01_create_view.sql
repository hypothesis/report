DROP VIEW IF EXISTS lms.users_sensitive CASCADE;

-- As this is a sensitive view, the data cannot remain at rest outside of the
-- region it was created. It MUST NOT be a `MATERIALIZED` view.
CREATE VIEW lms.users_sensitive AS (
    SELECT
        -- When specified in a where clause, Postgres is smart enough to only
        -- execute the branches of the UNION which are required.
        'us' AS region,
        CONCAT('us-', id) AS id,
        -- Include the non-concatenated id to allow for efficient remote
        -- filtering on where clauses as this is a non-materialized view.
        id AS remote_id,

        email,
        display_name
    FROM lms_us.users_sensitive

    UNION ALL

    SELECT
        'ca' AS region,
        CONCAT('ca-', id) AS id,
        id AS remote_id,
        email,
        display_name
    FROM lms_ca.users_sensitive
);
