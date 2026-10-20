WITH per_query AS (
    SELECT query_md5,
           AVG(label) FILTER (WHERE ov_bucket = '3_full')    AS full_label,
           AVG(label) FILTER (WHERE ov_bucket = '2_partial') AS partial_label
    FROM v
    GROUP BY 1
)
SELECT COUNT(*)                                                       AS queries_with_both,
       ROUND(AVG(full_label - partial_label), 3)                      AS full_minus_partial,
       ROUND(STDDEV(full_label - partial_label) / SQRT(COUNT(*)), 3)  AS std_error
FROM per_query
WHERE full_label IS NOT NULL AND partial_label IS NOT NULL
