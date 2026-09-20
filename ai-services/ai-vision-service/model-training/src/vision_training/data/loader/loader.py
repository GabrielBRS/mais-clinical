from __future__ import annotations

from pathlib import Path


def list_images(root: str | Path) -> list[Path]:
    path = Path(root)
    if not path.exists():
        return []
    return sorted(p for p in path.rglob("*") if p.suffix.lower() in {".jpg", ".png", ".ppm", ".jsonl"})
