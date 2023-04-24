DROP MATERIALIZED VIEW IF EXISTS hubspot.company_team_owners CASCADE;


-- This is a convenient de-normalized table for joining across companies, teams
-- and owners. We submerge the concept of the listed `company_owner` and
-- `success_owners` as listed in Hubspot, and rely on the teams instead to
-- differentiate. This means we can have once concept (team) instead of two (
-- team + ownership type).
CREATE MATERIALIZED VIEW hubspot.company_team_owners AS (
    WITH
        company_owners AS (
            SELECT
                id AS company_id,
                company_owner_id AS owner_id
            FROM hubspot.companies
            WHERE company_owner_id IS NOT NULL

            UNION

            SELECT
                id AS company_id,
                success_owner_id AS owner_id
            FROM hubspot.companies
            WHERE company_owner_id IS NOT NULL
        )

    SELECT
        companies.id AS company_id,
        companies.name AS company_name,
        teams.id AS team_id,
        teams.name AS team_name,
        owners.id AS owner_id,
        owners.name AS owner_name
        -- We want to be denormalized here and present the names along with the
        -- IDs as you almost always want these when presenting info in Reports.
        -- This greatly simplifies the queries and works around issues Metabase
        -- can have with repeated column names (like `id` and `name`).
    FROM company_owners
    JOIN hubspot.owner_teams ON
        owner_teams.owner_id = company_owners.owner_id
    JOIN hubspot.teams ON
        teams.id = owner_teams.team_id
    JOIN hubspot.companies ON
        companies.id = company_owners.company_id
    JOIN hubspot.owners ON
        owners.id = company_owners.owner_id
    ORDER BY companies.id,  team_id, company_owners.owner_id
) WITH NO DATA;
