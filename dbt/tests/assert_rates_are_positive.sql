-- Singular test: where a rate is present, it must be strictly positive.
-- Returns rows that violate the constraint (non-zero result = test failure).
select
    fx_date,
    variable,
    value
from {{ ref('stg_fx_rates') }}
where value is not null
    and value <= 0
