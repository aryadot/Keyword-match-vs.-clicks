-- Same lift by quintile of title BM25, which weights rare tokens and
-- normalizes for length instead of counting raw overlap.
WITH banded AS (
    SELECT *, NTILE(5) OVER (ORDER BY bm25_title) AS bm25_band FROM r
)
SELECT bm25_band,
       COUNT(*)                             AS n,
       ROUND(SUM(click) / SUM(pos_ctr), 3)  AS lift
FROM banded
GROUP BY 1
ORDER BY 1
