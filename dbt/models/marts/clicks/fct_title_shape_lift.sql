-- Full matches on queries of 5+ tokens, by title length relative to the query.
select
    {{ title_shape('title_length', 'query_length') }}  as title_shape,
    count(*)                                          as results,
    round(sum(click) / sum(expected_ctr), 3)          as lift
from {{ ref('int_click_results_adjusted') }}
where match_level = '3_full' and query_length >= 5
group by 1
order by 1
