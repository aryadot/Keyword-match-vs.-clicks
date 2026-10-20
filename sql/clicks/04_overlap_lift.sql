-- Lift = actual clicks / clicks expected from position alone.
SELECT ov_bucket,
       COUNT(*)                            AS n,
       ROUND(AVG(click), 4)                AS ctr,
       SUM(click)                          AS actual_clicks,
       ROUND(SUM(pos_ctr))                 AS expected_clicks,
       ROUND(SUM(click) / SUM(pos_ctr), 3) AS lift
FROM r
GROUP BY 1
ORDER BY 1
