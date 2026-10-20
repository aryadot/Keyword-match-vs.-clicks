"""Run every query in sql/ against the parquet files and save one CSV per query.

    python src/run_analysis.py --clicks data/clicks_part-0_split-0.parquet \
        --labels data/labels.parquet --out results/sample_a
    python src/run_analysis.py --clicks data/clicks_part-1_split-0.parquet \
        --out results/sample_b

Files in sql/<side>/ run in name order. 00_prepare.sql builds the working
table; every other file is a single SELECT saved as <name>.csv with the
numeric prefix dropped.
"""
import argparse
from pathlib import Path

import duckdb

SQL_DIR = Path(__file__).resolve().parent.parent / "sql"


def run_side(con, side, out_dir):
    for sql_file in sorted((SQL_DIR / side).glob("*.sql")):
        query = sql_file.read_text().strip().rstrip(";")
        if sql_file.name.startswith("00_"):
            con.execute(query)
            continue
        name = sql_file.stem.split("_", 1)[1]
        out_file = out_dir / f"{name}.csv"
        con.execute(f"COPY ({query}) TO '{out_file.as_posix()}' (HEADER, DELIMITER ',')")
        print(f"  {side}/{sql_file.name} -> {out_file}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--clicks", required=True, help="click parquet from download_data.py")
    parser.add_argument("--labels", help="expert-label parquet (optional)")
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect()

    con.execute(f"CREATE VIEW clicks_raw AS SELECT * FROM read_parquet('{Path(args.clicks).as_posix()}')")
    run_side(con, "clicks", out_dir)

    if args.labels:
        con.execute(f"CREATE VIEW labels_raw AS SELECT * FROM read_parquet('{Path(args.labels).as_posix()}')")
        run_side(con, "labels", out_dir)


if __name__ == "__main__":
    main()
