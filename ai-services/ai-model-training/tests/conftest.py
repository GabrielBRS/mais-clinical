from __future__ import annotations

from pathlib import Path
import shutil

import pytest

from llm_adaptation.recipe import Recipe, project_root


@pytest.fixture
def root(tmp_path: Path) -> Path:
    """Create a writable project fixture so tests never mutate repository artifacts."""

    source = project_root(Path(__file__).resolve())
    for directory in ("configs", "recipes"):
        shutil.copytree(source / directory, tmp_path / directory)
    samples = (
        "data/sft/sample.jsonl",
        "data/preference/chosen_rejected/sample.jsonl",
        "data/pretraining/sample.jsonl",
        "data/evaluation/golden/sample.jsonl",
    )
    for relative in samples:
        destination = tmp_path / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source / relative, destination)
    artifacts = tmp_path / "artifacts"
    artifacts.mkdir()
    (artifacts / "registry.json").write_text("[]")
    return tmp_path


@pytest.fixture
def sft_lora(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_lora.yaml", root=root)


@pytest.fixture
def sft_qlora(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_qlora.yaml", root=root)


@pytest.fixture
def sft_full(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_full.yaml", root=root)
