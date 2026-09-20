from __future__ import annotations


def classes(task: str) -> int:
    return {"classification": 2, "detection": 1, "segmentation": 2}.get(task, 1)
