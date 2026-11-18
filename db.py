"""Connect to the Neon Postgres database.

Connection strings come from .env.local, which `neon deploy` (or `neon env pull`)
writes and Git ignores. Never hard-code them here.

    from db import connect, read_sql

    with connect() as conn:
        conn.execute("SELECT 1")

    df = read_sql("SELECT * FROM players WHERE draft_year = %s", (2024,))
"""

import os
from pathlib import Path

import pandas as pd
import psycopg
from dotenv import load_dotenv

load_dotenv(Path(__file__).with_name(".env.local"))


def connect(direct: bool = False) -> psycopg.Connection:
    """Open a connection to Neon.

    direct=False uses the pooled URL (DATABASE_URL): use it for normal queries.
    direct=True uses DATABASE_URL_UNPOOLED: use it for creating tables, bulk
    loads with COPY, pg_dump, temp tables, or anything relying on SET.
    """
    var = "DATABASE_URL_UNPOOLED" if direct else "DATABASE_URL"
    url = os.environ.get(var)
    if not url:
        raise RuntimeError(f"{var} is not set. Run `neon env pull` to create .env.local.")
    return psycopg.connect(url)


def read_sql(query: str, params=None, direct: bool = False) -> pd.DataFrame:
    """Run a query and return the result as a pandas DataFrame."""
    with connect(direct) as conn, conn.cursor() as cur:
        cur.execute(query, params)
        columns = [c.name for c in cur.description]
        return pd.DataFrame(cur.fetchall(), columns=columns)


if __name__ == "__main__":
    # Quick connectivity check: `python3 db.py`
    print(read_sql("SELECT current_database() AS database, version() AS version").to_string(index=False))
