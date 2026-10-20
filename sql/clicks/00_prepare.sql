-- Working table: positions 1-9 only (10+ are too sparse for a stable CTR),
-- with query-title token overlap and the expected click rate for each position.
CREATE OR REPLACE TABLE r AS
WITH base AS (
    SELECT *,
           len(list_distinct(list_intersect(query, title))) * 1.0
             / NULLIF(len(list_distinct(query)), 0) AS overlap
    FROM clicks_raw
    WHERE position <= 9
),
bucketed AS (
    SELECT *,
           CASE WHEN overlap = 0   THEN '0_none'
                WHEN overlap < 0.5 THEN '1_low'
                WHEN overlap < 1   THEN '2_partial'
                ELSE '3_full' END AS ov_bucket
    FROM base
),
pos AS (SELECT position, AVG(click) AS pos_ctr FROM bucketed GROUP BY 1)
SELECT b.*, p.pos_ctr
FROM bucketed b JOIN pos p USING (position)
