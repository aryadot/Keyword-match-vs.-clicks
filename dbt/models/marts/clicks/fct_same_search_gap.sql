-- Full minus partial match within the same search, position adjusted.
with per_search as (
    select
        query_id,
        avg(click_residual) filter (where match_level = '3_full')    as full_residual,
        avg(click_residual) filter (where match_level = '2_partial') as partial_residual
    from {{ ref('int_click_results_adjusted') }}
    group by 1
)
select
    count(*)                                                           as searches_with_both,
    round(avg(full_residual - partial_residual), 4)                    as full_minus_partial,
    round(stddev(full_residual - partial_residual) / sqrt(count(*)), 4) as std_error
from per_search
where full_residual is not null and partial_residual is not null
