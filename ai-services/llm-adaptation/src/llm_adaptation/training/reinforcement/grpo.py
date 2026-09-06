from __future__ import annotations

from llm_adaptation.model.loader import DummyModel


def grpo_loss(model: DummyModel, group: list[list[int]], rewards: list[float]) -> float:
    if not group:
        return 0.0
    mean = sum(rewards) / len(rewards)
    return -sum(model.score(ids) * (reward - mean) for ids, reward in zip(group, rewards, strict=True))
