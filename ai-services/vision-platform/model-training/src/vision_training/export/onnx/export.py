from __future__ import annotations

from pathlib import Path


def export_onnx(recipe: str, dest: Path | None = None) -> Path:
    del recipe
    path = dest or Path("artifacts/onnx/model.onnx")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(b"ONNX-STUB")
    return path
