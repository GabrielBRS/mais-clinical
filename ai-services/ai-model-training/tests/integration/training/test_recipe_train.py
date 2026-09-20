from llm_adaptation.pipeline import evaluate_recipe, prepare_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def test_prepare_train_evaluate(sft_lora: Recipe) -> None:
    prepare_recipe(sft_lora)
    train_recipe(sft_lora)
    metrics = evaluate_recipe(sft_lora)
    assert metrics["examples"] >= 1
