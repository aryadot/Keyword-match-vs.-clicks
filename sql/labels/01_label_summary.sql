SELECT COUNT(*)                  AS rated_results,
       COUNT(DISTINCT query_md5) AS queries,
       ROUND(AVG(label), 3)      AS avg_label
FROM v
