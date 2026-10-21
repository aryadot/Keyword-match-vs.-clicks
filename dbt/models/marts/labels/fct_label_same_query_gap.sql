{{ config(enabled=var('include_labels')) }}

with per_query as (
    select
        query_key,
        avg(label) filter (where match_level = '3_full')    as full_label,
        avg(label) filter (where match_level = '2_partial') as partial_label
    from {{ ref('int_label_results') }}
    group by 1
)
select
    count(*)                                                        as queries_with_both,
    round(avg(full_label - partial_label), 3)                       as full_minus_partial,
    round(stddev(full_label - partial_label) / sqrt(count(*)), 3)   as std_error
from per_query
where full_label is not null and partial_label is not null
