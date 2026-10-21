select
    query_length_band,
    match_level,
    count(*)                                  as results,
    round(sum(click) / sum(expected_ctr), 3)  as lift
from {{ ref('int_click_results_adjusted') }}
group by 1, 2
order by 1, 2
