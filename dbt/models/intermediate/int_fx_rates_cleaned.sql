-- Intermediate: clean and enrich staged FX rates.
-- Renames variable -> currency, drops null/non-positive rates,
-- and adds eur_per_unit (how many EUR per one unit of the currency).
select
    fx_date,
    upper(trim(variable))                as currency,
    value                                as rate,
    1.0 / nullif(value, 0)               as eur_per_unit
from {{ ref('stg_fx_rates') }}
where value is not null
  and value > 0
