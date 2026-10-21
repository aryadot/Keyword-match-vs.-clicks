-- Joining the baseline must not lose or add results.
select
    (select count(*) from {{ ref('int_click_results') }})          as before_join,
    (select count(*) from {{ ref('int_click_results_adjusted') }}) as after_join
where (select count(*) from {{ ref('int_click_results') }})
   <> (select count(*) from {{ ref('int_click_results_adjusted') }})
