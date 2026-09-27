import importlib.util
from pathlib import Path

import pytest

from orzyon.knowledge import Knowledge


def test_retrieval_metrics(tmp_path: Path) -> None:
    spec = importlib.util.spec_from_file_location("evaluate", "scripts/evaluate_retrieval.py")
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    (tmp_path / "a.md").write_text("GPU memory")
    (tmp_path / "b.md").write_text("network")
    result = module.evaluate(
        Knowledge(tmp_path),
        [
            {"id": "hit", "query": "GPU", "relevant_sources": ["a.md"]},
            {"id": "miss", "query": "absent", "relevant_sources": ["b.md"]},
        ],
        2,
    )
    assert result["macro"]["recall_at_k"] == 0.5
    assert result["macro"]["precision_at_k"] == 0.25
    assert result["macro"]["reciprocal_rank"] == 0.5
    assert result["macro"]["ndcg_at_k"] == 0.5
    with pytest.raises(ValueError):
        module.evaluate(Knowledge(tmp_path), [], 2)
