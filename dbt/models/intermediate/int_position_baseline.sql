-- Expected click rate for each position: what a result earns from placement alone.
select
    position,
    count(*)    as results,
    avg(click)  as expected_ctr
from {{ ref('int_click_results') }}
group by 1
