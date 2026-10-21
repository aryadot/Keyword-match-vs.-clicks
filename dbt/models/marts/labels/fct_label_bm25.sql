{{ config(enabled=var('include_labels')) }}

with banded as (
    select *, ntile(5) over (order by bm25_title) as bm25_band
    from {{ ref('int_label_results') }}
)
select bm25_band, count(*) as results, round(avg(label), 3) as avg_label
from banded
group by 1
order by 1
