{{ config(enabled=var('include_labels')) }}

select
    match_level,
    count(*)                                                  as results,
    round(avg(label), 3)                                      as avg_label,
    round(avg(label) filter (where query_length >= 5), 3)     as avg_label_5plus_tokens
from {{ ref('int_label_results') }}
group by 1
order by 1
