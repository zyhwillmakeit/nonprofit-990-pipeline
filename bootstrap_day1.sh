#!/usr/bin/env bash
set -euo pipefail

REPO="nonprofit-990-pipeline"
mkdir -p "$REPO"
cd "$REPO"

mkdir -p src/nonprofit990 tests docs examples queries infra/terraform .github/workflows

cat > src/nonprofit990/__init__.py <<'EOF'
__all__ = ["__version__"]
__version__ = "0.1.0"
EOF

cat > src/nonprofit990/config.py <<'EOF'
from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
import os

@dataclass(frozen=True)
class AppConfig:
    env: str = os.getenv("APP_ENV", "dev")
    data_dir: Path = Path(os.getenv("DATA_DIR", "data"))
    log_level: str = os.getenv("LOG_LEVEL", "INFO")

def load_config() -> AppConfig:
    return AppConfig()
EOF

cat > src/nonprofit990/logging.py <<'EOF'
import logging
import json
from datetime import datetime, timezone

class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "msg": record.getMessage(),
        }
        if record.exc_info:
            payload["exc_info"] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False)

def setup_logging(level: str = "INFO") -> None:
    handler = logging.StreamHandler()
    handler.setFormatter(JsonFormatter())

    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(level)
EOF

cat > src/nonprofit990/cli.py <<'EOF'
from __future__ import annotations
import logging
import typer
from .config import load_config
from .logging import setup_logging

app = typer.Typer(add_completion=False)

@app.command()
def hello() -> None:
    """
    Smoke command to validate the repo setup.
    """
    cfg = load_config()
    setup_logging(cfg.log_level)
    logging.getLogger(__name__).info(f"hello | env={cfg.env} data_dir={cfg.data_dir}")

if __name__ == "__main__":
    app()
EOF

cat > tests/test_smoke.py <<'EOF'
from nonprofit990.config import load_config

def test_config_loads():
    cfg = load_config()
    assert cfg.env in {"dev", "prod"}
EOF

cat > examples/watchlist_ein.sample.csv <<'EOF'
ein
56-2669746
EOF

cat > docs/architecture.md <<'EOF'
# Architecture (v0)

## Goal
Given an EIN watchlist, ingest nonprofit Form 990 filings, land raw docs (Bronze), parse to Parquet (Silver), and publish analytics-ready tables (Gold) with data quality checks.

## Data Flow

```mermaid
flowchart LR
  A[watchlist_ein.csv] --> B[Ingest: filings manifest]
  B --> C[Download raw XML/PDF]
  C --> D[Bronze: object storage]
  D --> E[Parse + Normalize]
  E --> F[Silver: Parquet tables]
  F --> G[Transform + Model]
  G --> H[Gold: dim_org + fact_filing_financials]
  H --> I[Quality checks + report]
  H --> J[SQL query layer (DuckDB/Athena)]
