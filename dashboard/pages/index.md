---
title: Euro FX Reference Rates
---

## Latest Rates

```sql latest
    SELECT currency, rate, eur_per_unit, latest_date
    FROM mart_fx_latest
    ORDER BY currency
```

<DataTable data={latest} rows=30 search=true/>

## Historical Chart (monthly avg, major currencies)

```sql history
    SELECT month, currency, avg_rate
    FROM monthly_history
    ORDER BY month
```

<AreaChart
    data={history}
    title="ECB reference rate history (1 EUR = N units, monthly avg)"
    x=month
    y=avg_rate
    series=currency
/>
