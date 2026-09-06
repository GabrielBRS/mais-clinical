from __future__ import annotations

from pathlib import Path


def export_engine(dest: Path | None = None) -> Path:
    path = dest or Path("artifacts/tensorrt/model.engine")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"TRT-STUB")
    return path
