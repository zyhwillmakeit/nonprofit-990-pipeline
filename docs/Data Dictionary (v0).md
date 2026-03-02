# Data Dictionary (v0)

This document defines the v0 schemas for the pipeline’s **Gold** tables.

---

## `dim_org`

Organization dimension table (one row per EIN).

**Primary key:** `ein`

| Column | Type | Nullable | Description |
|---|---|---:|---|
| `ein` | string | no | Employer Identification Number (standardized, e.g. `56-2669746`) |
| `org_name` | string | yes | Organization legal name (best available) |
| `city` | string | yes | City of mailing address |
| `state` | string | yes | State of mailing address (2-letter) |
| `website` | string | yes | Organization website URL |
| `ntee_code` | string | yes | NTEE classification code (if available) |
| `updated_at` | timestamp | no | When this record was last updated by the pipeline |

**Notes**
- `ein` is stored in a consistent format (e.g., `NN-NNNNNNN`).
- `org_name`, `city`, `state`, `website`, `ntee_code` may be missing depending on filing/source coverage.

---

## `fact_filing_financials`

Filing-level fact table (one row per filing).

**Primary key:** `filing_id`  
**Foreign key:** `ein` → `dim_org.ein`

| Column | Type | Nullable | Description |
|---|---|---:|---|
| `filing_id` | string | no | Unique filing identifier from the source (used to deduplicate) |
| `ein` | string | no | Employer Identification Number |
| `tax_year` | int | no | Tax year covered by the filing (e.g., 2023) |
| `form_type` | string | yes | Filing form type (e.g., `990`, `990EZ`, `990PF`) |
| `filing_date` | date | yes | Filing/acceptance/submission date (if available) |
| `total_revenue` | double | yes | Total revenue for the tax year |
| `total_expenses` | double | yes | Total expenses for the tax year |
| `total_assets_eoy` | double | yes | Total assets at end of year |
| `total_liabilities_eoy` | double | yes | Total liabilities at end of year |
| `net_assets_eoy` | double | yes | Net assets at end of year (`assets_eoy - liabilities_eoy`) |
| `source` | string | no | Data source identifier (e.g., `irs`, `propublica`) |
| `ingested_at` | timestamp | no | When this filing was ingested/processed by the pipeline |

**Derived fields**
- `net_assets_eoy = total_assets_eoy - total_liabilities_eoy` (computed when both inputs are present; otherwise null)

**Data quality rules (v0)**
- Uniqueness: `filing_id` must be unique
- Completeness: `ein` and `tax_year` must be non-null
- Valid ranges:
  - `tax_year` between 1990 and current year (configurable later)
  - monetary fields should be `>= 0` when present (exceptions allowed if source contains negatives; will be tracked)
