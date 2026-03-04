# eurofxref-analytics

[![CI](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml/badge.svg)](https://github.com/atrakic/eurofxref-analytics/actions/workflows/ci.yml)
[![GitHub Pages](https://github.com/atrakic/eurofxref-analytics/actions/workflows/gh-pages.yml/badge.svg)](https://atrakic.github.io/eurofxref-analytics/)

> Lightweight ELT pipeline that fetches historical Euro foreign exchange rates from
[eurofxref-hist](https://csvbase.com/table-munger/eurofxref-hist), loads them into
DuckDB warehouse, and transforms them with dbt. Uses evidence.dev for data driven dashboard.

## Table of Contents

- [TL;DR](#tldr)
- [Stack](#stack)
- [Pipeline](#pipeline)
- [Development](#development)
  - [uv](#uv)
  - [Devbox](#devbox)
  - [Notebook](#notebook)
- [Project structure](#project-structure)
- [Dashboard](#dashboard)
  - [How it works](#how-it-works)
  - [GitHub Pages configuration](#github-pages-configuration)
  - [Performance](#performance)


## TL;DR

```
duckdb :memory:  -c "SET autoinstall_known_extensions=1; SET autoload_known_extensions=1; CREATE TABLE eurofxref_hist AS SELECT * FROM read_csv_auto(\"https://csvbase.com/table-munger/eurofxref-hist"); select * from eurofxref_hist;"
```

## Stack

| Layer | Tool |
|---|---|
| Storage | [DuckDB](https://duckdb.org/) |
| Transformation | [dbt-duckdb](https://github.com/duckdb/dbt-duckdb) |
| Dashboard | [Evidence](https://evidence.dev/) |
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

### Notebook

```bash
uv run jupyter notebook notebooks/
```

Open `Untitled-1.ipynb`. Run cell 1 to fetch data and populate the database, then run the remaining cells to explore and visualise the rates.

## Project structure

```
extract.py          # ETL script
dbt/                # dbt project config and profiles
dbt/models/
  staging/          # stg_fx_rates: raw data cleaned and typed
  intermediate/     # int_fx_rates_cleaned: filter nulls, add eur_per_unit
  marts/            # mart_fx_latest: latest exchange rates
dashboard/          # Evidence dashboard (GitHub Pages)
  pages/index.md    # dashboard page
  sources/eurofxref/
    connection.yaml         # DuckDB connection
    int_fx_rates_cleaned.sql
    mart_fx_latest.sql
    monthly_history.sql     # pre-aggregated monthly data for the chart
tests/              # pytest tests for the extract module
```

## Dashboard

**Live:** <https://atrakic.github.io/eurofxref-analytics/>

Built with [Evidence](https://evidence.dev/), a SQL-driven static site framework.
The dashboard is deployed to GitHub Pages on every push to `main` via
`.github/workflows/gh-pages.yml`.

### How it works

The GitHub Actions workflow:

1. **Extracts** data with `python extract.py` → populates `raw.fx_rates` in `duckdb.db`.
2. **Transforms** with `dbt run` → materialises `stg_fx_rates`, `int_fx_rates_cleaned`,
   and `mart_fx_latest` into `duckdb.db`.
3. **Copies** the fully-populated `duckdb.db` into `dashboard/` so Evidence can read it.
4. **Builds** the Evidence static site with `npm run sources && npm run build`.
5. **Deploys** the output to GitHub Pages.

### GitHub Pages configuration

GitHub Pages serves the site at a subpath (`/eurofxref-analytics/`), which requires
three things to be wired up correctly:

| File | Setting | Why |
|---|---|---|
| `dashboard/evidence.config.yaml` | `deployment.basePath: /eurofxref-analytics` | Tells Evidence to prefix all internal links and asset paths |
| `dashboard/package.json` | `"build": "EVIDENCE_BUILD_DIR=./build/eurofxref-analytics evidence build"` | Writes the static output into a subdirectory that matches the subpath |
| `.github/workflows/gh-pages.yml` | `path: dashboard/build/${{ github.event.repository.name }}` | Uploads the correct subdirectory as the Pages artifact |

Without all three aligned, assets are served from the wrong paths and the page
renders blank.

### Performance

Evidence bundles source query results as static JSON at build time.
Querying 30 k raw rows client-side was slow, so two pre-aggregated sources are
used instead:

- `monthly_history.sql` — averages daily rates by month (~300 rows) for the area chart.
- `mart_fx_latest.sql` — one row per currency for the latest-rates table.
