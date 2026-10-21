-- Each result with its position baseline. click_residual > 0 means more clicks
-- than its position alone would predict.
select
    r.*,
    b.expected_ctr,
    r.click - b.expected_ctr as click_residual
from {{ ref('int_click_results') }} r
join {{ ref('int_position_baseline') }} b using (position)
