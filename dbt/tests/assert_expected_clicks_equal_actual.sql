-- The position baseline is an average of the same rows it is applied to, so
-- total expected clicks must equal total actual clicks. A gap means the join
-- dropped or duplicated rows and every lift number is wrong.
select
    sum(click)         as actual_clicks,
    sum(expected_ctr)  as expected_clicks
from {{ ref('int_click_results_adjusted') }}
having abs(sum(click) - sum(expected_ctr)) > 0.5
