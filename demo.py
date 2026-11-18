import sys
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).parent.parent / "game-tracking-data-pipeline"))
from tracking import connect

games = pd.read_csv("combine-data/games.csv")
players = pd.read_csv("combine-data/players.csv")
player_play = pd.read_csv("combine-data/player_play.csv")
combine_results = pd.read_csv("combine-data/combine_results.csv")
combine_tracking = pd.read_csv("combine-data/combine_tracking.csv")
player_career_successes = pd.read_csv("combine-data/player_career_successes.csv")


connection = connect()
games_tracking_2025 = connection.execute("SELECT * FROM game_tracking_2025 LIMIT 54").df()

def get_player_rows(nfl_id):
    """Return the matching rows for nfl_id from each CSV that has a player id.
    """
    return {
        "players": players[players["nfl_id"] == nfl_id],
        "player_play": player_play[player_play["nfl_id"] == nfl_id],
        "combine_results": combine_results[combine_results["nfl_id"] == nfl_id],
        "combine_tracking": combine_tracking[combine_tracking["nfl_id"] == nfl_id],
        "player_career_successes": player_career_successes[
            player_career_successes["nfl_id"] == nfl_id
        ],
    }

print(games_tracking_2025.columns)
print(games_tracking_2025.head())
