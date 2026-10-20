-- If the ranker sorted by literal match, overlap would fall with position.
-- A flat line means position isn't confounding the overlap comparison.
SELECT position, ROUND(AVG(overlap), 3) AS avg_overlap
FROM r
GROUP BY 1
ORDER BY 1
