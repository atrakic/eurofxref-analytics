---
title: Euro FX Reference Rates
---

```sql history
    SELECT fx_date, currency, rate
    FROM memory.eurofxref.int_fx_rates_cleaned
    WHERE currency IN ('USD', 'JPY', 'CHF', 'GBP', 'CNY')
    ORDER BY fx_date
```

<AreaChart
    data={history}
    title="ECB reference rate history (1 EUR = N units)"
    x=fx_date
    y=rate
    series=currency
/>
