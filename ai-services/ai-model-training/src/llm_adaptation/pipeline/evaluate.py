from __future__ import annotations

import json

from llm_adaptation.data import TokenizedExample
from llm_adaptation.evaluation import evaluate
from llm_adaptation.model.checkpoint import Checkpoint
from llm_adaptation.pipeline.train import _examples
from llm_adaptation.recipe import Recipe


def evaluate_recipe(recipe: Recipe) -> dict:
    ckpt = recipe.root / "artifacts" / "checkpoints" / recipe.name
    model, _ = Checkpoint.read(ckpt) if (ckpt / "checkpoint.json").exists() else (None, None)
    if model is None:
        from llm_adaptation.model import ModelConfig, load_model

        model = load_model(ModelConfig.from_dict(recipe.model))
    examples = _examples(recipe)
    metrics = evaluate(model, examples)
    dest = recipe.root / "artifacts" / "evaluations" / recipe.name
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "metrics.json").write_text(json.dumps(metrics, indent=2))
    return metrics
