from llm_adaptation.pipeline import prepare_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def test_sft_lora_smoke(sft_lora: Recipe) -> None:
    prepare_recipe(sft_lora)
    result = train_recipe(sft_lora)
    assert result["adapter"] == "lora"
    assert (sft_lora.root / "artifacts/adapters" / sft_lora.name / "adapter.json").exists()
