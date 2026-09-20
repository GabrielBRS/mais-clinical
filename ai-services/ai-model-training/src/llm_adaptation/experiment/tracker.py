from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.experiment.run import Run


class Tracker:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def log(self, run: Run) -> None:
        with self.path.open("a") as handle:
            handle.write(json.dumps({"id": run.id, "name": run.name, "metrics": run.metrics}) + "\n")
