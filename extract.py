import duckdb
import pandas as pd
import requests
from io import StringIO

URL = "https://csvbase.com/calpaterson/eurofxref-hist"


def fetch_fx_data(url: str = URL) -> pd.DataFrame:
    r = requests.get(url, timeout=30)
    r.raise_for_status()
    df = pd.read_csv(StringIO(r.text))
    df.columns = [c.lower() for c in df.columns]
    return df


def load_to_duckdb(df: pd.DataFrame, db_path: str = "duckdb.db") -> None:
    con = duckdb.connect(db_path)
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    con.execute("DROP TABLE IF EXISTS raw.fx_rates")
    con.execute("CREATE TABLE raw.fx_rates AS SELECT * FROM df")
    con.close()


def main():
    df = fetch_fx_data()
    load_to_duckdb(df)


if __name__ == "__main__":
    main()
