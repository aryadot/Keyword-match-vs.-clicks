-- Expert-annotated set, same overlap definition and buckets as the click side.
-- query_md5 is the query key because ~8% of query_id values repeat.
CREATE OR REPLACE TABLE v AS
WITH base AS (
    SELECT *,
           len(list_distinct(list_intersect(query, title))) * 1.0
             / NULLIF(len(list_distinct(query)), 0) AS overlap
    FROM labels_raw
)
SELECT *,
       CASE WHEN overlap = 0   THEN '0_none'
            WHEN overlap < 0.5 THEN '1_low'
            WHEN overlap < 1   THEN '2_partial'
            ELSE '3_full' END AS ov_bucket
FROM base
