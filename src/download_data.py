"""Download Baidu-ULTR files from Hugging Face and keep only the columns this
analysis needs, saved as parquet.

Each click file is ~0.95 GB, mostly a 768-dim embedding per result that this
project never uses, so it is dropped on read.

    python src/download_data.py --shard parts/part-0_split-0.feather --labels
    python src/download_data.py --shard parts/part-1_split-0.feather
"""
import argparse
from pathlib import Path

import pyarrow.feather as feather
import pyarrow.parquet as pq
from huggingface_hub import hf_hub_download

REPO = "philipphager/baidu-ultr_baidu-mlm-ctr"

CLICK_COLUMNS = ["query_id", "query", "title", "position", "media_type", "click",
                 "bm25_title", "query_length", "title_length", "displayed_time"]
LABEL_COLUMNS = ["query_md5", "query", "title", "label", "frequency_bucket",
                 "bm25_title", "query_length", "title_length"]


def fetch(filename, columns, out_path):
    path = hf_hub_download(REPO, filename, repo_type="dataset")
    table = feather.read_table(path, columns=columns)
    pq.write_table(table, out_path)
    print(f"{filename}: {table.num_rows:,} rows -> {out_path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--shard", default="parts/part-0_split-0.feather",
                        help="click file inside the Hugging Face repo")
    parser.add_argument("--labels", action="store_true",
                        help="also download the expert-annotated validation file")
    parser.add_argument("--data-dir", default="data")
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    data_dir.mkdir(exist_ok=True)

    stem = Path(args.shard).stem
    fetch(args.shard, CLICK_COLUMNS, data_dir / f"clicks_{stem}.parquet")
    if args.labels:
        fetch("parts/validation.feather", LABEL_COLUMNS, data_dir / "labels.parquet")


if __name__ == "__main__":
    main()
