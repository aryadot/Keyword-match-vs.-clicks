-- Short queries are almost always full matches and get few clicks, which
-- could drive the pooled pattern. Lengths are Chinese tokens.
SELECT CASE WHEN query_length <= 2 THEN '1-2 tokens'
            WHEN query_length <= 4 THEN '3-4 tokens'
            ELSE '5+ tokens' END            AS q_len,
       ov_bucket,
       COUNT(*)                             AS n,
       ROUND(SUM(click) / SUM(pos_ctr), 3)  AS lift
FROM r
GROUP BY 1, 2
ORDER BY 1, 2
