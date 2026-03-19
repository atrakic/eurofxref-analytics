---
title: Euro FX Reference Rates
---

```sql kpis
    SELECT
        COUNT(DISTINCT currency) AS total_currencies,
        MAX(latest_date) AS latest_date,
        MAX(CASE WHEN currency = 'USD' THEN rate END)         AS usd_rate,
        MAX(CASE WHEN currency = 'GBP' THEN rate END)         AS gbp_rate,
        MAX(CASE WHEN currency = 'JPY' THEN rate END)         AS jpy_rate,
        MAX(CASE WHEN currency = 'CHF' THEN rate END)         AS chf_rate
    FROM mart_fx_latest
```

<BigValue data={kpis} value=total_currencies title="Currencies Tracked"/>
<BigValue data={kpis} value=latest_date title="Latest Data" fmt="date"/>
<BigValue data={kpis} value=usd_rate title="EUR / USD" fmt="num2"/>
<BigValue data={kpis} value=gbp_rate title="EUR / GBP" fmt="num4"/>
<BigValue data={kpis} value=jpy_rate title="EUR / JPY" fmt="num2"/>
<BigValue data={kpis} value=chf_rate title="EUR / CHF" fmt="num4"/>

---

```sql major_currencies
    SELECT currency, rate
    FROM mart_fx_latest
    WHERE currency IN ('USD', 'GBP', 'JPY', 'CHF', 'CNY', 'AUD', 'CAD', 'SEK', 'NOK', 'DKK')
    ORDER BY rate DESC
```

```sql history
    SELECT month, currency, avg_rate
    FROM monthly_history
    ORDER BY month
```

<Grid cols=2>
<BarChart
    data={major_currencies}
    title="Major Currency Rates (1 EUR = N units)"
    x=currency
    y=rate
    swapXY=true
/>
<LineChart
    data={history}
    title="Monthly Average Rate History"
    x=month
    y=avg_rate
    series=currency
/>
</Grid>

---

## All Rates

```sql latest
    SELECT currency, rate, eur_per_unit, latest_date
    FROM mart_fx_latest
    ORDER BY currency
```

<DataTable data={latest} rows=30 search=true/>
