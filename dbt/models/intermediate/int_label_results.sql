{{ config(enabled=var('include_labels')) }}

with results as (
    select *, {{ token_overlap('query_tokens', 'title_tokens') }} as overlap
    from {{ ref('stg_labels') }}
    where len(query_tokens) > 0
)
select *, {{ match_level('overlap') }} as match_level
from results
