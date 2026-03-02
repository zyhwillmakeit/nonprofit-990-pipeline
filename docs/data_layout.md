# Data Layout (v0)

This document defines the planned storage layout for the pipeline.

## Bronze (raw, immutable)
Raw documents are stored as-is for traceability and reprocessing.

- `bronze/ein=.../tax_year=.../filing_id=.../raw.xml`
- `bronze/ein=.../tax_year=.../filing_id=.../raw.pdf`

Notes:
- Partition keys: `ein`, `tax_year`
- `filing_id` is the unique identifier for a filing within a year.

## Silver (parsed, normalized Parquet)
Parsed outputs with stable schemas for downstream transforms.

- `silver/org_profile.parquet`
- `silver/filing_financials.parquet`

## Gold (analytics-ready Parquet)
Star-schema style tables for query and BI.

- `gold/dim_org.parquet`
- `gold/fact_filing_financials.parquet`
