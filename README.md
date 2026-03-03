# eurofxref-analytics

[![CI](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml/badge.svg)](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml)

> Lightweight ELT pipeline that fetches historical Euro foreign exchange rates from
[eurofxref-hist](https://csvbase.com/calpaterson/eurofxref-hist), loads them into
DuckDB, and transforms them with dbt.


## TLD;R

```
duckdb :memory:  -c "SET autoinstall_known_extensions=1; SET autoload_known_extensions=1; CREATE TABLE eurofxref_hist AS SELECT * FROM read_csv_auto(\"https://csvbase.com/calpaterson/eurofxref-hist\"); select * from eurofxref_hist;"
```

## Stack

| Layer | Tool |
|---|---|
| Storage | [DuckDB](https://duckdb.org/) |
| Transformation | [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) |
| Dev environment | [Devbox](https://www.jetify.com/devbox) |
| CI | GitHub Actions |

## Pipeline

```
1. CSV (eurofxref-hist)
        |
        \/
2. Extract (Python, uv)
  -> extract.py          # fetch and load into raw.fx_rates (DuckDB)
        |
        \/
3. Load -> DuckDB (raw schema)
        |
        \/
4. Transform (dbt models)
        |
        \/
5. Analytics layers
  -> stg_fx_rates          # dbt view:  cast types, normalise columns
  -> int_fx_rates_cleaned  # dbt view:  filter nulls, add eur_per_unit
  -> mart_fx_latest        # dbt table: most recent rate per currency
        |
        \/
6. CI via GitHub Actions
```

## Development

### uv

```bash
# Install dependencies
uv sync --all-groups

# Fetch source data and populate DuckDB
uv run python extract.py

# Run dbt models
uv run dbt run --project-dir dbt --profiles-dir dbt

# Run dbt tests
uv run dbt test --project-dir dbt --profiles-dir dbt

# Run Python tests
uv run pytest
```

### Devbox
> https://www.jetify.com/docs/devbox

```bash
devbox shell          # installs uv and syncs dependencies automatically
devbox run pipeline   # extract -> dbt run -> dbt test
devbox run test       # pytest only
devbox run dbt-docs   # generate dbt documentation
```

## Project structure

```
extract.py          # ETL script
dbt/                # dbt project config and profiles
dbt/models/
  staging/          # stg_fx_rates: raw data cleaned and typed
  intermediate/     # int_fx_rates_cleaned: filter nulls, add eur_per_unit
  marts/            # mart_fx_latest: latest exchange rates
tests/              # pytest tests for the extract module
```
