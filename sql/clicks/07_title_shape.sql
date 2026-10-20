-- Full matches on 5+ token queries: does a title that is little more than
-- the query itself do worse than one that adds information?
SELECT CASE WHEN title_length <= query_length * 1.5 THEN '1_near_copy'
            WHEN title_length <= query_length * 3   THEN '2_moderate'
            ELSE '3_much_longer' END        AS title_shape,
       COUNT(*)                             AS n,
       ROUND(SUM(click) / SUM(pos_ctr), 3)  AS lift
FROM r
WHERE ov_bucket = '3_full' AND query_length >= 5
GROUP BY 1
ORDER BY 1
