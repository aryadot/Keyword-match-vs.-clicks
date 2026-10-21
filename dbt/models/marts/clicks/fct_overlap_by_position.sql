-- Flat values mean the ranker isn't ordering results by literal match,
-- so position doesn't confound the match level comparison.
select position, round(avg(overlap), 3) as avg_overlap
from {{ ref('int_click_results') }}
group by 1
order by 1
