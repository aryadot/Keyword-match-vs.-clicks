{{ config(enabled=var('include_labels')) }}

select
    {{ title_shape('title_length', 'query_length') }}  as title_shape,
    count(*)                                          as results,
    round(avg(label), 3)                              as avg_label
from {{ ref('int_label_results') }}
where match_level = '3_full' and query_length >= 5
group by 1
order by 1
