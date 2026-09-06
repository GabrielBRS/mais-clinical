from __future__ import annotations

from pathlib import Path

import pytest

from llm_adaptation.recipe import Recipe, project_root


@pytest.fixture
def root() -> Path:
    return project_root(Path(__file__).resolve())


@pytest.fixture
def sft_lora(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_lora.yaml", root=root)


@pytest.fixture
def sft_qlora(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_qlora.yaml", root=root)


@pytest.fixture
def sft_full(root: Path) -> Recipe:
    return Recipe.load(root / "recipes/qwen/sft_full.yaml", root=root)
