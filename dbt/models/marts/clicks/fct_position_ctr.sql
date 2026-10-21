-- All positions, including the sparse tail excluded from the adjusted analysis.
select position, count(*) as results, round(avg(click), 4) as ctr
from {{ ref('stg_clicks') }}
group by 1
order by 1
