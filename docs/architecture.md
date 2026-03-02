# Architecture (v0)

## Goal
Build a reproducible data pipeline that turns a user-provided **EIN watchlist** into:
- **Bronze**: raw Form 990 documents (XML/PDF)
- **Silver**: parsed, normalized Parquet tables
- **Gold**: analytics-ready dim/fact tables
- **Data Quality**: automated validation + quality report

This project is intentionally scoped to **watchlist-only** (not full-corpus crawling).

---

## High-level data flow

```mermaid
flowchart LR
  A["Input: watchlist_ein.csv"] --> B["Ingest: filings manifest (incremental)"]
  B --> C["Download raw XML/PDF"]
  C --> D["Bronze: partitioned raw storage"]
  D --> E["Parse and normalize"]
  E --> F["Silver: Parquet tables"]
  F --> G["Modeling + transforms"]
  G --> H["Gold: dim/fact tables"]
  H --> I["Data quality checks + quality report"]
