# eurofxref-analytics

[![CI](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml/badge.svg)](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml)

> Lightweight ELT pipeline that fetches historical Euro foreign exchange rates from
[eurofxref-hist](https://csvbase.com/calpaterson/eurofxref-hist), loads them into
DuckDB, and transforms them with dbt.



## Stack

| Layer | Tool |
|---|---|
| Package management | [uv](https://docs.astral.sh/uv/) |
| Storage | [DuckDB](https://duckdb.org/) |
| Transformation | [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) |
| CI | GitHub Actions |

## Pipeline

```
CSV (eurofxref-hist)
  -> extract.py          # fetch and load into raw.fx_rates (DuckDB)
  -> stg_fx_rates        # dbt view: cast types, normalise columns
  -> mart_fx_latest      # dbt table: most recent rate per currency
```

## Usage

```bash
# Install dependencies
uv sync

# Fetch source data and populate DuckDB
uv run python extract.py

# Run dbt models
uv run dbt run --project-dir dbt --profiles-dir dbt

# Run dbt tests
uv run dbt test --project-dir dbt --profiles-dir dbt

# Run Python tests
uv run pytest
```

## Project structure

```
extract.py          # ETL script
dbt/                # dbt project config and profiles
models/
  staging/          # stg_fx_rates: raw data cleaned and typed
  marts/            # mart_fx_latest: latest exchange rates
tests/              # pytest tests for the extract module
```
