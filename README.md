# Keyword Match vs. Clicks

Search ads are often written to repeat the searcher's exact words. This project tests whether people actually click those titles, using about a million real search results from Baidu.

**Short answer: not as often as you'd expect.** Within the same search, titles that contain every query word get about 15% fewer clicks than titles that only partly match, even though expert raters score them as more relevant. The result held on a second, independent sample.

**[View the interactive analysis](https://aryadot.github.io/keyword-match-vs-clicks/dashboard/)**

<!-- Add a screenshot of the dashboard here, e.g. ![Dashboard preview](docs/screenshots/dashboard.png) -->

## Table of Contents
- [Key Findings](#key-findings)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Full Analysis](#full-analysis)
- [Data and License](#data-and-license)

## Key Findings

- **Experts and users disagree at the full match.** Expert ratings rise all the way to a word-for-word match; clicks peak at a partial match and then drop.
- **The more a title just repeats the query, the bigger the gap.** Near-copy titles are rated highest and clicked least.
- **Relevance still matters.** A weighted text-match score (BM25) rises with both clicks and expert ratings. What backfires is repeating the query, not relevance itself.

Every comparison is adjusted for position on the page, since the top result gets about 20 times the clicks of the ninth.

## Project Structure

```
├── dashboard/      interactive write-up, opens in any browser
├── dbt/            the analysis: staging, intermediate and mart models, plus tests
├── src/            data download and CSV export scripts
├── docs/           full analysis write-up
└── results/        generated output
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/aryadot/keyword-match-vs-clicks.git
cd keyword-match-vs-clicks
```

2. Install dependencies (Python 3.10+):
```bash
pip install -r requirements.txt
```

3. Download the data (about 1 GB per click file):
```bash
python src/download_data.py --shard parts/part-0_split-0.feather --labels
python src/download_data.py --shard parts/part-1_split-0.feather
```

## Usage

Run the analysis and its tests:
```bash
cd dbt
dbt build --profiles-dir .
```

Run the replication on the second sample:
```bash
dbt build --profiles-dir . --target sample_b \
    --vars '{clicks_path: "../data/clicks_part-1_split-0.parquet", include_labels: false}'
```

View the model lineage and documentation:
```bash
dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir .
```

Export the results to CSV:
```bash
cd ..
python src/export_results.py --db dbt/sample_a.duckdb --out results/sample_a
python src/export_results.py --db dbt/sample_b.duckdb --out results/sample_b
```

To see the findings without running anything, open the [interactive analysis](https://aryadot.github.io/keyword-match-vs-clicks/dashboard/), or open `dashboard/index.html` in a browser after cloning.

## Full Analysis

The complete analysis is the [interactive report](https://aryadot.github.io/keyword-match-vs-clicks/dashboard/) (`dashboard/index.html`): the question, the position adjustment, the main finding, four robustness checks including the replication, and limitations.

A text version with the full results tables is in [docs/analysis.md](docs/analysis.md).

## Data and License

Data comes from the [Baidu-ULTR dataset](https://huggingface.co/datasets/philipphager/baidu-ultr_baidu-mlm-ctr) released by Baidu, using the preprocessed version on Hugging Face. It's used here for non-commercial research.

The code in this repository is licensed under the [MIT License](LICENSE).