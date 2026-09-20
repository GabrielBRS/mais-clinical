from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.model.loader import DummyModel


def write_safetensors(model: DummyModel, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps({"weights": {str(k): v for k, v in model.weights.items()}}))
    return dest
