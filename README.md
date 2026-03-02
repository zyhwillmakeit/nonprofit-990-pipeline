# nonprofit-990-pipeline

A data engineering portfolio project: **EIN watchlist → Form 990 ingestion → Bronze raw storage → Silver Parquet → Gold analytics tables → data quality checks → (optional) cloud query**.

This project turns a manual workflow (searching nonprofit filings and hand-collecting metrics) into a reproducible pipeline with clear data contracts, idempotent ingestion, and cloud-ready storage layout.

---

## What this does

Given a CSV of EINs (watchlist), the pipeline will:

1. **Ingest**: discover available filings for each EIN (manifest-driven, incremental)
2. **Bronze**: download and store raw filing documents (XML/PDF) with partitioned paths
3. **Silver**: parse filings into normalized structured Parquet tables
4. **Gold**: publish analytics-ready tables (dim/fact) for SQL queries
5. **Data Quality**: validate schema/uniqueness/completeness and generate a quality report

Data sources: primarily official filings from the **:contentReference[oaicite:0]{index=0}**, optionally cross-checked via **:contentReference[oaicite:1]{index=1}**.

---

## Architecture (v0)

```mermaid
flowchart LR
  A["watchlist_ein.csv"] --> B["Ingest: filings manifest"]
  B --> C["Download raw XML/PDF"]
  C --> D["Bronze storage"]
  D --> E["Parse and normalize"]
  E --> F["Silver Parquet"]
  F --> G["Gold tables"]
  G --> H["Data quality checks and report"]
  G --> I["Query layer: local DuckDB or cloud Athena"]
