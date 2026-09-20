from __future__ import annotations


def effective_batch(micro: int, accumulation: int, world_size: int = 1) -> int:
    return micro * accumulation * world_size
