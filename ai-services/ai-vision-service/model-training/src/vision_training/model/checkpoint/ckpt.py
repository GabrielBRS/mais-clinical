from __future__ import annotations

import json
from pathlib import Path


def write_checkpoint(path: Path, metrics: dict[str, float]) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    (path / "metrics.json").write_text(json.dumps(metrics))
    return path
