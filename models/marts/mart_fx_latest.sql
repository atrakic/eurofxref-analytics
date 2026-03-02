with ranked as (

    select
        *,
        row_number() over (
            partition by 1
            order by fx_date desc
        ) as rn
    from {{ ref('stg_fx_rates') }}

)

select *
from ranked
where rn = 1
