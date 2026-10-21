# Analysis write-up

The full method, results and limitations behind the project. For setup and usage, see the [main README](../README.md).

## Data

[Baidu-ULTR](https://huggingface.co/datasets/philipphager/baidu-ultr_baidu-mlm-ctr) is a large set of real search sessions from Baidu, with query and title text released as anonymized token IDs.

| Sample | File | Searches | Results | CTR |
|---|---|---|---|---|
| Analysis | `part-0_split-0` | 64,200 | 524,164 | 8.4% |
| Replication | `part-1_split-0` | 64,249 | 524,983 | 8.4% |
| Expert labels | `validation` | separate queries | 397,522 rated results | — |

Each click row is one result shown for one search, with its position, whether it was clicked, and precomputed text-match features. The expert set has a 0–4 relevance label for each query–result pair but no clicks, and it covers different queries from the click logs.

## Method

**Position adjustment.** CTR falls from 34% at position 1 to about 1.6% at position 9, so raw CTR mostly measures placement. For every result I used the average CTR at its position as the expected click rate, and report **lift** = actual clicks ÷ expected clicks. Positions 10 and below were dropped because they are too sparse.

**Keyword overlap.** The share of the query's distinct tokens that appear in the title, grouped as none, low (< 50%), partial (50–99%) and full (100%). Average overlap is flat across positions (0.73–0.76), so Baidu's ranker isn't sorting by literal match, and position doesn't confound the comparison.

**Same-search comparison.** Pooled comparisons mix different kinds of searches. For each search that showed both a full-match and a partial-match result, I took each result's residual (click minus expected), averaged by match type, and differenced them. The reported gap is the mean of those differences, with a standard error across searches. The expert side uses the same design across queries.

**Robustness checks**
- Split by query length, since short queries are almost always full matches.
- Split full matches by how much the title adds beyond the query.
- Repeated the analysis with BM25, a weighted text-match score, in place of raw overlap.
- Reran every click-side query on a second, independent file.

## Pipeline

The analysis is a dbt project on DuckDB (`dbt/`), built in three layers:

- **Staging** reads the parquet files: `stg_clicks`, `stg_labels`.
- **Intermediate** builds the shared logic once: token overlap and match level per result (`int_click_results`), the expected click rate per position (`int_position_baseline`), and each result's residual against it (`int_click_results_adjusted`).
- **Marts** hold one table per finding, such as `fct_match_level_lift`, `fct_same_search_gap` and `fct_title_shape_lift`, plus the expert-label versions.

The sample is a variable, so the replication is the same build pointed at a different file and written to its own database. Every model and key column is documented, and `dbt docs generate` produces the lineage graph.

Tests run on every build. Alongside standard checks (no missing keys, match levels limited to the four allowed values, one baseline row per position), three tests guard the logic the results depend on:

- **Total expected clicks equal total actual clicks.** The baseline is an average over the same rows it's applied to, so any gap means the join broke and every lift figure is wrong.
- **The position adjustment keeps every result.** Row counts before and after the join must match.
- **The top position outclicks the last analyzed position.** This is a warning, not a failure: a sanity check that the position field behaves as expected.

Building the tests turned up one edge case: a query with no tokens has undefined overlap, and the original query would have silently counted it as a full match. Those rows are now excluded and tested for.

## Results

**Clicks and expert ratings move apart at the full match**

| Overlap | Click lift | Expert rating (0–4) |
|---|---|---|
| None | 0.83 | 0.35 |
| Low | 1.00 | 0.36 |
| Partial | **1.09** | 0.87 |
| Full | 0.90 | **1.53** |

**Same-search difference, full minus partial**

| | Gap | Std. error | n |
|---|---|---|---|
| Click probability | −1.26 pts | 0.12 pts | 38,733 searches |
| Expert rating | +0.45 | 0.011 | 4,157 queries |

The click gap is roughly 15% of average CTR and about 10 standard errors from zero. The rating gap points the opposite way.

**The more a title just echoes the query, the wider the split.** Among full matches on queries of 5+ tokens:

| Title length vs. query | Click lift | Expert rating |
|---|---|---|
| Near copy (≤ 1.5×) | 0.92 | 1.92 |
| Moderate (≤ 3×) | 0.94 | 1.73 |
| Much longer | 1.03 | 1.38 |

**Relevance itself still matters.** Across BM25 quintiles, click lift rises from 0.85 to 1.09 and expert ratings from 0.46 to 1.22. A better text-match signal tracks both clicks and ratings; what loses clicks is word-for-word repetition.

**Query length explains part of the pooled effect, not all of it.** Queries of 1–2 tokens get low lift (~0.65) at every overlap level and are 90% full matches, which drags the pooled full-match number down. On 5+ token queries, where most of the data sits, partial matches still beat full matches (1.10 vs 0.96). On 3–4 token queries the order reverses (full 0.79, partial 0.69). That reversal showed up in both samples, so I'm treating it as real rather than noise.

**Replication**

| Result | Sample A | Sample B |
|---|---|---|
| Same-search click gap | −1.26 pts | −1.16 pts |
| Lift, partial / full | 1.085 / 0.903 | 1.093 / 0.895 |
| Lift on 5+ token queries, partial / full | 1.098 / 0.957 | 1.111 / 0.946 |
| Near copy → much longer title | 0.919 → 1.027 | 0.895 → 1.010 |
| BM25 lowest → highest band | 0.849 → 1.088 | 0.849 → 1.097 |

## What I take from it

Relevance and appeal line up until a title matches the query word for word, and then they separate. Expert labels and keyword overlap both treat the full match as the best result; searchers pick it less often than a title that shares some of their words and adds something else. I came to this through an interest in adtech, where headlines are routinely written to mirror the search and relevance is often judged by exactly these two signals. This suggests the title that looks most relevant on paper isn't always the one people choose.

## Limitations

- **Fewer clicks don't necessarily mean a worse result.** A title that restates the question may already answer it on the results page ("good abandonment"). These logs can't separate that from users skipping it.
- **Organic results, not ads.** The relevance-vs-engagement tension is the same, but these aren't ad CTRs.
- **Different query sets.** Clicks and expert labels come from different queries, so the disagreement is between patterns rather than on identical results.
- **Observational data.** Rankings weren't randomized. Position adjustment, same-search comparisons and replication reduce confounding but don't remove it.
- **Token-level text.** Query and title text are anonymized token IDs, so overlap is token overlap, and lengths are Chinese tokens rather than words.

## Next steps

- An A/B test of ad titles: full keyword match vs. a partial match that adds information, measured on clicks and conversions.
- Use display time to test whether near-copy titles hold attention without a click, which would point to good abandonment.
- Repeat on sponsored results specifically.

## Acknowledgments

Data from the Baidu-ULTR dataset released by Baidu (Zou et al., *A Large Scale Search Dataset for Unbiased Learning to Rank*, NeurIPS 2022 Datasets and Benchmarks Track), using the preprocessed release on Hugging Face by Philipp Hager. Used for non-commercial research.
