import duckdb
import pandas as pd
from extract import fetch_fx_data, load_to_duckdb


def test_fetch_fx_data_returns_dataframe():
    df = fetch_fx_data()
    assert isinstance(df, pd.DataFrame)
    assert "date" in df.columns
    assert len(df) > 0


def test_load_to_duckdb_creates_table(tmp_path):
    db_file = tmp_path / "test.duckdb"

    # minimal fake dataframe (fast test)
    df = pd.DataFrame({"date": ["2024-01-01"], "usd": [1.1]})

    load_to_duckdb(df, str(db_file))

    con = duckdb.connect(str(db_file))
    result = con.execute("SELECT COUNT(*) FROM raw.fx_rates").fetchone()[0]
    con.close()

    assert result == 1
