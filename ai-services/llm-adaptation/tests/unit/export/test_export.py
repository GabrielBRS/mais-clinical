from pathlib import Path

from llm_adaptation.export import export_merged, write_huggingface
from llm_adaptation.model import ModelConfig, load_model
from llm_adaptation.model.checkpoint import Checkpoint
from llm_adaptation.training.peft import attach_lora


def test_merge_and_hf(tmp_path: Path) -> None:
    model = load_model(ModelConfig(name="dummy"))
    attach_lora(model)
    model.step([1, 2], [1, 2], 0.2)
    src = tmp_path / "ckpt"
    Checkpoint(src, {"loss": 1.0}).write(model)
    dest = export_merged(src, tmp_path / "merged")
    merged, _ = Checkpoint.read(dest)
    assert merged.adapter is None
    write_huggingface(merged, dest)
    assert (dest / "config.json").exists()
