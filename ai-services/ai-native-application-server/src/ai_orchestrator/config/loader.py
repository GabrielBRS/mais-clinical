from __future__ import annotations

import tomllib
from pathlib import Path
from typing import Any


def load_toml(env: str, root: Path | None = None) -> dict[str, Any]:
    base = root or Path(__file__).resolve().parents[3]
    path = base / "config" / f"{env}.toml"
    if not path.exists():
        return {}
    return tomllib.loads(path.read_text())
