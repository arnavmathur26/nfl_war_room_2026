-- Creates and loads the shared tables in Neon (database: neondb).
-- Run from inside combine-data/ so the \copy filenames resolve:
--   cd combine-data
--   set -a; source ../.env.local; set +a
--   psql "$DATABASE_URL_UNPOOLED" -v ON_ERROR_STOP=1 -f ../setup.sql
--
-- WARNING: this DROPS and recreates every table below, so rerunning it
-- replaces whatever is in them. It runs as one transaction: if any step
-- fails, nothing is changed.
-- Game tracking data is not loaded here; it lives in Parquet (see tracking.py).

BEGIN;

DROP TABLE IF EXISTS combine_results;
CREATE TABLE combine_results (
    draft_year INTEGER,
    nfl_id  INTEGER,
    combine_position TEXT,
    combine_height NUMERIC(5, 3),
    combine_weight SMALLINT,
    hand_size NUMERIC(5, 3),
    arm_length NUMERIC(5,3),
    wing_span NUMERIC(5,3),
    ten_yd_split NUMERIC(3, 2),
    forty NUMERIC(3,2),
    vertical NUMERIC(3,1),
    broad_jump SMALLINT,
    three_cone NUMERIC(3,2),
    short_shuttle NUMERIC(3,2),
    bench_reps SMALLINT,
    ngs_athleticism_score SMALLINT,
    ngs_college_production_score SMALLINT,
    ngs_final_score SMALLINT
);

\copy combine_results FROM 'combine_results.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');


DROP TABLE IF EXISTS combine_tracking;
CREATE TABLE combine_tracking (
    draft_year SMALLINT,
    event_id TEXT,
    nfl_id INTEGER,
    entity_type TEXT,
    time TIMESTAMP,
    drill_type TEXT,
    drill_name TEXT,
    attempt SMALLINT,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    s DOUBLE PRECISION,
    a DOUBLE PRECISION,
    dis DOUBLE PRECISION,
    dir DOUBLE PRECISION
);

\copy combine_tracking FROM 'combine_tracking.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');


DROP TABLE IF EXISTS games;
CREATE TABLE games (
    game_id INTEGER,
    game_key INTEGER,
    season SMALLINT,
    season_type TEXT,
    week SMALLINT,
    home_team_abbr TEXT,
    visitor_team_abbr TEXT
);

\copy games FROM 'games.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');


DROP TABLE IF EXISTS players;
CREATE TABLE players (
    nfl_id INTEGER,
    display_name TEXT,
    draft_year SMALLINT,
    nfl_position TEXT,
    birth_date DATE,
    college_name TEXT,
    college_conference TEXT,
    draft_round SMALLINT,
    draft_pick_within_round SMALLINT,
    draft_overall_pick SMALLINT
);

\copy players FROM 'players.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');


DROP TABLE IF EXISTS player_career_successes;
CREATE TABLE player_career_successes (
    nfl_id INTEGER,
    career_offensive_snaps SMALLINT,
    career_defensive_snaps SMALLINT,
    career_special_teams_snaps SMALLINT,
    career_games_active SMALLINT,
    career_games_started SMALLINT,
    ap_all_pro_1st_team SMALLINT,
    ap_all_pro_2nd_team SMALLINT,
    pro_bowl_original_ballot SMALLINT
);

\copy player_career_successes FROM 'player_career_successes.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');


DROP TABLE IF EXISTS player_play;
CREATE TABLE player_play (
    game_id INTEGER,
    play_id INTEGER,
    team_abbr TEXT,
    nfl_id INTEGER,
    lined_up_position TEXT,
    play_description TEXT,
    quarter SMALLINT,
    down SMALLINT,
    yards_to_go SMALLINT,
    possession_team TEXT,
    yardline_side TEXT,
    yardline_number SMALLINT,
    game_clock TEXT,
    pre_snap_home_score SMALLINT,
    pre_snap_visitor_score SMALLINT,
    play_direction TEXT,
    pre_snap_home_team_win_probability NUMERIC(9,6),
    pre_snap_visitor_team_win_probability NUMERIC(9,6),
    home_team_win_probability_added NUMERIC(9,6),
    visitor_team_win_probility_added NUMERIC(9,6),
    expected_points_added NUMERIC(9,6),
    expected_points NUMERIC(9,6),
    offense_formation TEXT,
    receiver_alignment TEXT,
    pass_result TEXT,
    pass_length SMALLINT,
    play_nullified_by_penalty TEXT,
    penalty_yards SMALLINT,
    pre_penalty_yards_gained SMALLINT,
    yards_gained SMALLINT,
    team_coverage_man_zone TEXT,
    team_coverage_type TEXT,
    in_motion_at_ball_snap BOOLEAN,
    target BOOLEAN,
    rec_yards SMALLINT,
    rush_yards SMALLINT,
    yards_after_catch SMALLINT,
    fumble SMALLINT,
    fumble_lost SMALLINT,
    route_ran TEXT,
    separation_at_pass_forward NUMERIC(6,3),
    cushion NUMERIC(6,3),
    expected_yards_after_catch NUMERIC(6,3),
    dropback_duration NUMERIC(6,3),
    extended_sack_allowed NUMERIC(2,1),
    pass_rushers_encountered SMALLINT,
    peak_pressure_probability_allowed NUMERIC(9,6),
    pressure_allowed BOOLEAN,
    sack_allowed NUMERIC(2,1),
    time_to_pressure_allowed NUMERIC(6,3),
    quick_pressure BOOLEAN,
    unblocked_pressure BOOLEAN,
    blitzing BOOLEAN,
    player_get_off NUMERIC(6,3),
    sack NUMERIC(2,1),
    tackle SMALLINT,
    assist SMALLINT,
    caused_forced_fumble SMALLINT,
    recovered_fumble BOOLEAN,
    tackle_for_loss BOOLEAN,
    time_to_pressure NUMERIC(6,3),
    time_to_qb_hurry NUMERIC(6,3),
    coverage_assignment TEXT,
    coverage_assignment_at_snap TEXT
);

\copy player_play FROM 'player_play.csv' WITH (FORMAT csv, HEADER true, NULL 'NA');

COMMIT;
