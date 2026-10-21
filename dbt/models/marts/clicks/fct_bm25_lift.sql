with banded as (
    select *, ntile(5) over (order by bm25_title) as bm25_band
    from {{ ref('int_click_results_adjusted') }}
)
select
    bm25_band,
    count(*)                                  as results,
    round(sum(click) / sum(expected_ctr), 3)  as lift
from banded
group by 1
order by 1
