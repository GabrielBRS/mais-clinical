from __future__ import annotations

from pathlib import Path
from uuid import uuid4

from llm_adaptation.host_api import execute
from llm_adaptation.pipeline import prepare_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def host_request(operation: str, root: Path) -> dict[str, object]:
    return {
        "schema_version": "1.0",
        "operation": operation,
        "run_id": str(uuid4()),
        "root": str(root),
        "recipe_path": "recipes/qwen/sft_lora.yaml",
    }


def test_prepare_matches_legacy_python_api(root: Path) -> None:
    recipe = Recipe.load(root / "recipes/qwen/sft_lora.yaml", root=root)
    legacy = prepare_recipe(recipe)
    hosted = execute(host_request("prepare_data", root))
    assert hosted["status"] == "succeeded"
    assert hosted["data"] == legacy


def test_train_matches_legacy_python_api(root: Path) -> None:
    recipe = Recipe.load(root / "recipes/qwen/sft_lora.yaml", root=root)
    legacy = train_recipe(recipe)
    hosted = execute(host_request("train", root))
    assert hosted["status"] == "succeeded"
    assert hosted["data"]["adapter"] == legacy["adapter"]
    assert hosted["data"]["loss"] == legacy["loss"]
