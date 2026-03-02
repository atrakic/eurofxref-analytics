with latest as (
    select
        *,
        row_number() over (partition by currency order by fx_date desc) as rn
    from {{ ref('int_fx_rates_cleaned') }}
)
select
    currency,
    rate,
    eur_per_unit,
    fx_date as latest_date
from latest
where rn = 1
order by currency
