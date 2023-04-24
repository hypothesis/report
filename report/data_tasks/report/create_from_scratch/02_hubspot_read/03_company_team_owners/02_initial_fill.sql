DROP INDEX IF EXISTS hubspot.company_team_owners_company_id_team_id_owner_id_idx;

REFRESH MATERIALIZED VIEW hubspot.company_team_owners;

ANALYSE hubspot.company_team_owners;

-- A unique index is mandatory for concurrent updates used in the refresh
CREATE UNIQUE INDEX company_team_owners_company_id_team_id_owner_id_idx ON hubspot.company_team_owners (company_id, team_id, owner_id);
