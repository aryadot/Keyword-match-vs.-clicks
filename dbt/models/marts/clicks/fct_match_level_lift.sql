select
    match_level,
    count(*)                                   as results,
    round(avg(click), 4)                       as ctr,
    sum(click)                                 as actual_clicks,
    round(sum(expected_ctr), 1)                as expected_clicks,
    round(sum(click) / sum(expected_ctr), 3)   as lift
from {{ ref('int_click_results_adjusted') }}
group by 1
order by 1
