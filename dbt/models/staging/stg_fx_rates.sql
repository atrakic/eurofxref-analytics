select date::date as fx_date,
    csvbase_row_id,
    currency,
    rate
from raw.fx_rates