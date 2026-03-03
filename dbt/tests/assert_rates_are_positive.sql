-- Singular test: where a rate is present, it must be strictly positive.
-- Returns rows that violate the constraint (non-zero result = test failure).
select
    fx_date,
    currency,
    rate
from {{ ref('stg_fx_rates') }}
where rate is not null
    and rate <= 0
