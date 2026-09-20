from __future__ import annotations

from collections.abc import Callable


class EvaluationCallback:
    def __init__(self, fn: Callable[[], dict[str, float]] | None = None) -> None:
        self.fn = fn
        self.history: list[dict[str, float]] = []

    def on_epoch(self) -> dict[str, float]:
        metrics = self.fn() if self.fn else {}
        self.history.append(metrics)
        return metrics
