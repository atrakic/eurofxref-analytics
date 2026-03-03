select
    date::date   as fx_date,
    csvbase_row_id,
    variable,
    value
from raw.fx_rates
