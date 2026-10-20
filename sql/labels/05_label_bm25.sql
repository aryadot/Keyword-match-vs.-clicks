WITH banded AS (
    SELECT *, NTILE(5) OVER (ORDER BY bm25_title) AS bm25_band FROM v
)
SELECT bm25_band, COUNT(*) AS n, ROUND(AVG(label), 3) AS avg_label
FROM banded
GROUP BY 1
ORDER BY 1
