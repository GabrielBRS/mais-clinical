from llm_adaptation.pipeline import prepare_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def test_sft_qlora_smoke(sft_qlora: Recipe) -> None:
    prepare_recipe(sft_qlora)
    result = train_recipe(sft_qlora)
    assert result["adapter"] == "qlora"
