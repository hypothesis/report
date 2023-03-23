DROP TABLE IF EXISTS hubspot.owner_teams CASCADE;

CREATE TABLE hubspot.owner_teams (
    owner_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL
);

CREATE UNIQUE INDEX owner_teams_owner_id_team_id_idx ON hubspot.owner_teams (owner_id, team_id);
