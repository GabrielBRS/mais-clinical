"""Recipe YAML — fragments em configs/ + overlay em recipes/."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


def project_root(start: Path | None = None) -> Path:
    cur = (start or Path.cwd()).resolve()
    for path in (cur, *cur.parents):
        if (path / "pyproject.toml").exists() and (path / "recipes").is_dir():
            return path
    return cur


def load_yaml(path: Path) -> dict[str, Any]:
    return yaml.safe_load(path.read_text()) or {}


def _deep_merge(base: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    out = dict(base)
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(out.get(key), dict):
            out[key] = _deep_merge(out[key], value)
        else:
            out[key] = value
    return out


@dataclass(slots=True)
class Recipe:
    name: str
    path: Path
    root: Path
    model: dict[str, Any] = field(default_factory=dict)
    data: dict[str, Any] = field(default_factory=dict)
    training: dict[str, Any] = field(default_factory=dict)
    distributed: dict[str, Any] = field(default_factory=dict)
    evaluation: dict[str, Any] = field(default_factory=dict)
    raw: dict[str, Any] = field(default_factory=dict)

    @property
    def method(self) -> str:
        return str(self.training.get("method", "sft"))

    @property
    def adapter(self) -> str:
        return str(self.training.get("adapter", "none"))

    @classmethod
    def load(cls, path: str | Path, root: Path | None = None) -> Recipe:
        recipe_path = Path(path).resolve()
        project = root or project_root(recipe_path.parent)
        raw = load_yaml(recipe_path)
        merged: dict[str, Any] = {}
        for key, rel in (raw.get("extends") or {}).items():
            fragment = project / rel
            merged[key] = load_yaml(fragment)
        for key in ("model", "data", "training", "distributed", "evaluation"):
            if key in raw and isinstance(raw[key], dict):
                merged[key] = _deep_merge(merged.get(key, {}), raw[key])
        return cls(
            name=str(raw.get("name") or recipe_path.stem),
            path=recipe_path,
            root=project,
            model=merged.get("model", {}),
            data=merged.get("data", {}),
            training=merged.get("training", {}),
            distributed=merged.get("distributed", {}),
            evaluation=merged.get("evaluation", {}),
            raw=raw,
        )
