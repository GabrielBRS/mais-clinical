from llm_adaptation.pipeline import prepare_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def test_sft_full_smoke(sft_full: Recipe) -> None:
    prepared = prepare_recipe(sft_full)
    assert prepared["train"] >= 1
    result = train_recipe(sft_full)
    assert result["adapter"] == "none"
    assert "loss" in result
