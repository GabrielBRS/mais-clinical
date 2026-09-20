from __future__ import annotations

import logging

_log = logging.getLogger("llm_adaptation.train")


class LogCallback:
    def __init__(self) -> None:
        self.steps: list[tuple[int, float]] = []

    def on_step(self, step: int, loss: float) -> None:
        self.steps.append((step, loss))
        if step == 1 or step % 50 == 0:
            _log.info("step=%s loss=%.4f", step, loss)
