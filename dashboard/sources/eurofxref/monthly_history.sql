SELECT
    DATE_TRUNC('month', fx_date)::date AS month,
    currency,
    ROUND(AVG(rate), 4) AS avg_rate
FROM int_fx_rates_cleaned
WHERE currency IN ('USD', 'JPY', 'CHF', 'GBP', 'CNY')
GROUP BY 1, 2
ORDER BY 1
