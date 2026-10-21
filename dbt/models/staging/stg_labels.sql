{{ config(enabled=var('include_labels')) }}

-- query_md5 is the query key: about 8% of query_id values repeat in this file.
select
    query_md5    as query_key,
    label,
    query        as query_tokens,
    title        as title_tokens,
    query_length,
    title_length,
    bm25_title
from read_parquet('{{ var("labels_path") }}')
