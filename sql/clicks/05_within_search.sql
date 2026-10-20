-- Full vs partial match inside the same search. Residual = click minus the
-- position's average CTR, averaged per bucket within a search, differenced,
-- then averaged across searches that showed both kinds of result.
WITH per_search AS (
    SELECT query_id,
           AVG(click - pos_ctr) FILTER (WHERE ov_bucket = '3_full')    AS full_resid,
           AVG(click - pos_ctr) FILTER (WHERE ov_bucket = '2_partial') AS partial_resid
    FROM r
    GROUP BY 1
)
SELECT COUNT(*)                                                       AS searches_with_both,
       ROUND(AVG(full_resid - partial_resid), 4)                      AS full_minus_partial,
       ROUND(STDDEV(full_resid - partial_resid) / SQRT(COUNT(*)), 4)  AS std_error
FROM per_search
WHERE full_resid IS NOT NULL AND partial_resid IS NOT NULL
