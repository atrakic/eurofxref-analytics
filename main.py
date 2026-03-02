import duckdb
import pandas as pd
import requests
from io import StringIO

URL = "https://csvbase.com/calpaterson/eurofxref-hist"

def main():
    print("Downloading FX data...")
    r = requests.get(URL)
    r.raise_for_status()

    df = pd.read_csv(StringIO(r.text))
    df.columns = [c.lower() for c in df.columns]

    con = duckdb.connect("duckdb.db")
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    con.execute("DROP TABLE IF EXISTS raw.fx_rates")
    con.execute("CREATE TABLE raw.fx_rates AS SELECT * FROM df")

    print("Loaded raw.fx_rates")

if __name__ == "__main__":
    main()
