# eurofxref-analytics

## Flow
```
1. CSV (eurofxref-hist)
        |
        \/
2. Extract (Python, uv)
        |
        \/
3. Load -> DuckDB (raw schema)
        |
        \/
4. Transform (dbt models)
        |
        \/
5. Analytics marts
        |
        \/
6. CI via GitHub Actions
```
