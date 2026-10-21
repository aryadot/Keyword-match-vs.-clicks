-- One row per result shown in positions 1 to max_position, with its match level.
-- Queries with no tokens are dropped: overlap is undefined for them.
with results as (
    select *, {{ token_overlap('query_tokens', 'title_tokens') }} as overlap
    from {{ ref('stg_clicks') }}
    where position <= {{ var('max_position') }}
      and len(query_tokens) > 0
)
select
    *,
    {{ match_level('overlap') }}             as match_level,
    {{ query_length_band('query_length') }}  as query_length_band
from results
