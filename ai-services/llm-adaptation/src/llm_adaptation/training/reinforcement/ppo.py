from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def ppo_loss(model: DummyModel, ids: list[int], reward: float, *, clip: float = 0.2) -> float:
    ratio = 1.0 + model.score(ids) * 0.01
    clipped = max(min(ratio, 1.0 + clip), 1.0 - clip)
    return -min(ratio * reward, clipped * reward)
