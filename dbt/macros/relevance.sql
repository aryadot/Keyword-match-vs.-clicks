{# Share of the query's distinct tokens that also appear in the title. #}
{% macro token_overlap(query_col, title_col) %}
    len(list_distinct(list_intersect({{ query_col }}, {{ title_col }}))) * 1.0
        / len(list_distinct({{ query_col }}))
{% endmacro %}

{# Four match levels used throughout the analysis. #}
{% macro match_level(overlap_col) %}
    case
        when {{ overlap_col }} = 0   then '0_none'
        when {{ overlap_col }} < 0.5 then '1_low'
        when {{ overlap_col }} < 1   then '2_partial'
        else '3_full'
    end
{% endmacro %}

{# Full matches only: how much the title says beyond the query. #}
{% macro title_shape(title_len, query_len) %}
    case
        when {{ title_len }} <= {{ query_len }} * 1.5 then '1_near_copy'
        when {{ title_len }} <= {{ query_len }} * 3   then '2_moderate'
        else '3_much_longer'
    end
{% endmacro %}

{% macro query_length_band(query_len) %}
    case
        when {{ query_len }} <= 2 then '1-2 tokens'
        when {{ query_len }} <= 4 then '3-4 tokens'
        else '5+ tokens'
    end
{% endmacro %}
