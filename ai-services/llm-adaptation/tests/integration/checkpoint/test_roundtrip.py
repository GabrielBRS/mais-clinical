from pathlib import Path

from llm_adaptation.model import ModelConfig, load_model
from llm_adaptation.model.checkpoint import Checkpoint


def test_checkpoint_roundtrip(tmp_path: Path) -> None:
    model = load_model(ModelConfig(name="round"))
    model.weights[3] = 1.5
    path = tmp_path / "ckpt"
    Checkpoint(path, {"loss": 0.2}).write(model)
    loaded, ckpt = Checkpoint.read(path)
    assert loaded.weights[3] == 1.5
    assert ckpt.metrics["loss"] == 0.2
