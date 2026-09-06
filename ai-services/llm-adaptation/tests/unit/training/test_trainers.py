from pathlib import Path

from llm_adaptation.data import TokenizedExample
from llm_adaptation.model import ModelConfig, load_model
from llm_adaptation.training import TrainConfig
from llm_adaptation.training.peft import attach_lora, merge_adapter
from llm_adaptation.training.sft import SFTTrainer


def test_sft_writes_checkpoint(tmp_path: Path) -> None:
    model = load_model(ModelConfig(name="dummy"))
    examples = [TokenizedExample("1", [2, 5, 6], [2, 5, 6])]
    result = SFTTrainer().run(model, examples, TrainConfig(output_dir=tmp_path / "ckpt"))
    assert (result.checkpoint / "checkpoint.json").exists()
    assert result.metrics["steps"] >= 1


def test_lora_merges() -> None:
    model = load_model(ModelConfig())
    attach_lora(model, rank=4, alpha=8)
    model.step([3, 4], [3, 4], 0.1)
    merge_adapter(model)
    assert model.adapter is None
    assert model.weights
