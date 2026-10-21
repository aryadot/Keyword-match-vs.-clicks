{{ config(severity='warn') }}
-- Sanity check on the data itself: if the top result doesn't outclick the
-- last analyzed position, the position field isn't behaving as expected.
with b as (select * from {{ ref('int_position_baseline') }})
select *
from b as top
cross join b as bottom
where top.position = 1
  and bottom.position = {{ var('max_position') }}
  and top.expected_ctr <= bottom.expected_ctr
