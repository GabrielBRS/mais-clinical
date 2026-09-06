from __future__ import annotations

from llm_adaptation.export import export_merged, write_huggingface
from llm_adaptation.export.quantize import quantize
from llm_adaptation.model.checkpoint import Checkpoint
from llm_adaptation.recipe import Recipe


def export_recipe(recipe: Recipe) -> dict:
    ckpt = recipe.root / "artifacts" / "checkpoints" / recipe.name
    merged = recipe.root / "artifacts" / "merged" / recipe.name
    quantized = recipe.root / "artifacts" / "quantized" / recipe.name
    export_merged(ckpt, merged)
    model, _ = Checkpoint.read(merged)
    write_huggingface(model, merged)
    quantize(merged, quantized, bits=4)
    return {"merged": str(merged), "quantized": str(quantized)}
