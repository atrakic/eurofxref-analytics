-- Intermediate: clean and enrich staged FX rates.
-- Source is already long-format (one row per date/currency).
-- Normalises currency code and adds eur_per_unit.
select
    fx_date,
    upper(trim(currency))          as currency,
    rate,
    1.0 / nullif(rate, 0)          as eur_per_unit
from {{ ref('stg_fx_rates') }}
where rate is not null
  and rate > 0
