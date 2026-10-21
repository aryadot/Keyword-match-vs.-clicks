"""Write every fct_ table from a dbt build to CSV.

    python src/export_results.py --db dbt/sample_a.duckdb --out results/sample_a
"""
import argparse
from pathlib import Path

import duckdb


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--db", required=True, help="DuckDB file written by dbt build")
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(args.db, read_only=True)

    tables = [row[0] for row in con.execute(
        "select table_name from information_schema.tables "
        "where table_name like 'fct_%' order by 1").fetchall()]
    for name in tables:
        out_file = out_dir / f"{name}.csv"
        con.execute(f"COPY {name} TO '{out_file.as_posix()}' (HEADER, DELIMITER ',')")
        print(f"{name} -> {out_file}")


if __name__ == "__main__":
    main()
