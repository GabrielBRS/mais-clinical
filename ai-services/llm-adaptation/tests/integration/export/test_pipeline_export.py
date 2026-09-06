from llm_adaptation.pipeline import export_recipe, prepare_recipe, publish_recipe, train_recipe
from llm_adaptation.recipe import Recipe


def test_export_and_publish(sft_lora: Recipe) -> None:
    prepare_recipe(sft_lora)
    train_recipe(sft_lora)
    exported = export_recipe(sft_lora)
    assert (sft_lora.root / "artifacts/merged" / sft_lora.name / "config.json").exists()
    published = publish_recipe(sft_lora)
    assert published["published"] == sft_lora.name
    assert exported["merged"]
