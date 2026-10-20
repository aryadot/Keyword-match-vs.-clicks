-- CTR by rank, all positions: how much position alone drives clicks.
SELECT position, COUNT(*) AS n, ROUND(AVG(click), 4) AS ctr
FROM clicks_raw
GROUP BY 1
ORDER BY 1
