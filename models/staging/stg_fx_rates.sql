select
    date::date as fx_date,
    *
exclude(date)
from raw.fx_rates
