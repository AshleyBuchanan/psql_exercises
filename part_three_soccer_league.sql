DROP DATABASE IF EXISTS soccer_league;

CREATE DATABASE soccer_league;

\c soccer_league

CREATE TABLE Seasons (
    season_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE Teams (
    team_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    region_id INT REFERENCES Regions(region_id)
);

CREATE TABLE Players (
    player_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    position TEXT,
    team_id INT REFERENCES Teams(team_id)
);

CREATE TABLE Referees (
    referee_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    region_id INT REFERENCES Regions(region_id)
);

CREATE TABLE Matches (
    match_id SERIAL PRIMARY KEY,
    home_team_id INT REFERENCES Teams(team_id),
    away_team_id INT REFERENCES Teams(team_id),
    season_id INT REFERENCES Seasons(season_id),
    referee_id INT REFERENCES Referees(referee_id),
    match_date DATE NOT NULL,
    home_score INT DEFAULT 0,
    away_score INT DEFAULT 0
);

CREATE TABLE Goals (
    goal_id SERIAL PRIMARY KEY,
    match_id INT REFERENCES Matches(match_id),
    player_id INT REFERENCES Players(player_id),
    team_id INT REFERENCES Teams(team_id),
    minute_scored INT
);

--It was suggested that I use Coalesce/Sum
CREATE OR REPLACE VIEW Standings AS
SELECT
    t.team_id,
    t.name AS team_name,
    COALESCE(SUM(CASE
        WHEN (t.team_id = m.home_team_id AND m.home_score > m.away_score)
          OR (t.team_id = m.away_team_id AND m.away_score > m.home_score)
        THEN 1 ELSE 0 END), 0) AS wins,
    COALESCE(SUM(CASE
        WHEN (t.team_id = m.home_team_id AND m.home_score < m.away_score)
          OR (t.team_id = m.away_team_id AND m.away_score < m.home_score)
        THEN 1 ELSE 0 END), 0) AS losses,
    COALESCE(SUM(CASE
        WHEN m.home_score = m.away_score AND (t.team_id = m.home_team_id OR t.team_id = m.away_team_id)
        THEN 1 ELSE 0 END), 0) AS draws,
    (COALESCE(SUM(CASE
        WHEN (t.team_id = m.home_team_id AND m.home_score > m.away_score)
          OR (t.team_id = m.away_team_id AND m.away_score > m.home_score)
        THEN 1 ELSE 0 END), 0) * 3
     +
     COALESCE(SUM(CASE
        WHEN m.home_score = m.away_score AND (t.team_id = m.home_team_id OR t.team_id = m.away_team_id)
        THEN 1 ELSE 0 END), 0)
    ) AS points
FROM Teams t
    LEFT JOIN Matches m
    ON t.team_id = m.home_team_id OR t.team_id = m.away_team_id
GROUP BY t.team_id, t.name;

