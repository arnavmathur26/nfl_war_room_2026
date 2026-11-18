import duckdb
import pandas as pd
from pathlib import Path
import os
from dotenv import load_dotenv


ROOT = Path("/Users/arnavmathur/Downloads/SAG/Big Data Bowl 2027/nfl-big-data-bowl-2027")
load_dotenv(ROOT / ".env.local")

PARQUET_DIR = ROOT.parent / "game-tracking-data"

def connect():
    files = sorted(PARQUET_DIR.glob("game_tracking_*.parquet"))
    if not files:
        raise RuntimeError(f"No Parquet files in {PARQUET_DIR}. Run convert_to_parquet.py first.")

    connection = duckdb.connect()
    connection.execute(f"""
        CREATE VIEW game_tracking AS
        SELECT * FROM read_parquet('{PARQUET_DIR}/game_tracking_*.parquet', union_by_name = true)
    """)
    for f in files:
        connection.execute(f"CREATE VIEW {f.stem} AS SELECT * FROM read_parquet('{f}')")
    return connection

def read_sql(query, params=None, connection=None):
    connection = connection or connect()
    return connection.execute(query, params).df()

def attach_postgres(connection, direct=False):
    var = "DATABASE_URL_UNPOOLED" if direct else "DATABASE_URL"
    url = os.environ.get(var)
    if not url:
        raise RuntimeError(f"{var} is not set. Run `neon env pull` to create .env.local.")
    connection.execute("INSTALL postgres")
    connection.execute("LOAD postgres")
    connection.execute(f"ATTACH '{url}' AS pg (TYPE postgres, READ_ONLY)")
