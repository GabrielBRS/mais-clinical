from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.model.loader import DummyModel


def write_huggingface(model: DummyModel, dest: Path) -> Path:
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "config.json").write_text(
        json.dumps(
            {
                "model_type": model.config.family,
                "architectures": ["DummyForCausalLM"],
                "name": model.config.name,
            },
            indent=2,
        )
    )
    (dest / "README.md").write_text(f"# {model.config.name}\n")
    return dest
