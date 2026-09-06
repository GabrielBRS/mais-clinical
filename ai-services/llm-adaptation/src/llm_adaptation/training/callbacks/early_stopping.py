from __future__ import annotations


class EarlyStopping:
    def __init__(self, patience: int = 3) -> None:
        self.patience = patience
        self.best = float("inf")
        self.bad = 0
        self.should_stop = False

    def on_epoch(self, loss: float) -> None:
        if loss < self.best:
            self.best = loss
            self.bad = 0
            return
        self.bad += 1
        self.should_stop = self.bad >= self.patience
