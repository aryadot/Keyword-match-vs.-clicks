select
    count(*)                  as results,
    count(distinct query_id)  as searches,
    round(avg(click), 4)      as ctr
from {{ ref('stg_clicks') }}
