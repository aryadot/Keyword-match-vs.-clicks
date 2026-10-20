SELECT ov_bucket,
       COUNT(*)                                               AS n,
       ROUND(AVG(label), 3)                                   AS avg_label,
       ROUND(AVG(label) FILTER (WHERE query_length >= 5), 3)  AS avg_label_5plus_tokens
FROM v
GROUP BY 1
ORDER BY 1
