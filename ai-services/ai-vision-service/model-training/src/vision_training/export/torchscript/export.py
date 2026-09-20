from __future__ import annotations

from pathlib import Path


def export_ts(dest: Path | None = None) -> Path:
    path = dest or Path("artifacts/torchscript/model.pt")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"TS-STUB")
    return path
