from vision_training.evaluation.classification.metrics import accuracy
from vision_training.training.classification.trainer import train_classifier


def test_train_classifier(tmp_path) -> None:
    metrics = train_classifier("recipes/classification/dummy.yaml", output=tmp_path / "ckpt")
    assert metrics["acc"] > 0.9
    assert (tmp_path / "ckpt" / "metrics.json").exists()


def test_accuracy() -> None:
    assert accuracy([1, 0, 1], [1, 0, 0]) == 2 / 3
