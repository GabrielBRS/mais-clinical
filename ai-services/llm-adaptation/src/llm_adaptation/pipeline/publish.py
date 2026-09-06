from __future__ import annotations

from llm_adaptation.recipe import Recipe
from llm_adaptation.registry import ModelRegistry
from llm_adaptation.registry.metadata import ModelMeta


def publish_recipe(recipe: Recipe) -> dict:
    registry = ModelRegistry(recipe.root / "artifacts" / "registry.json")
    meta = ModelMeta(
        name=recipe.name,
        version="0.1.0",
        family=str(recipe.model.get("family", "qwen")),
        method=recipe.method,
    )
    registry.register(meta)
    return {"published": meta.name, "version": meta.version, "count": len(registry.list())}
