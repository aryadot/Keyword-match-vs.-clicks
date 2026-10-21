select
    query_id,
    position,
    click,
    query        as query_tokens,
    title        as title_tokens,
    query_length,
    title_length,
    bm25_title
from read_parquet('{{ var("clicks_path") }}')
