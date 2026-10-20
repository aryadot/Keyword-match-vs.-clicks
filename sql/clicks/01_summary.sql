SELECT COUNT(*)                 AS results,
       COUNT(DISTINCT query_id) AS searches,
       ROUND(AVG(click), 4)     AS ctr
FROM clicks_raw
