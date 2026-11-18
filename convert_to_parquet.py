import duckdb
from pathlib import Path

TRACKING = Path(__file__).resolve().parent.parent / "game-tracking-data"

for csv in sorted(TRACKING.glob("game_tracking_*.csv")):
    out = csv.with_suffix(".parquet")
    duckdb.sql(f"""
               COPY (SELECT * FROM read_csv('{csv}', nullstr='NA'))
               TO '{out}' (FORMAT parquet, COMPRESSION zstd)
            """)
    print("wrote", out)

