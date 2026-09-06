from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.registry.metadata import ModelMeta


class ModelRegistry:
    def __init__(self, path: Path) -> None:
        self.path = path
        self._items: list[dict[str, str]] = []
        if path.exists():
            self._items = json.loads(path.read_text())

    def register(self, meta: ModelMeta) -> None:
        self._items.append(
            {"name": meta.name, "version": meta.version, "family": meta.family, "method": meta.method}
        )
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(self._items, indent=2))

    def list(self) -> list[dict[str, str]]:
        return list(self._items)
