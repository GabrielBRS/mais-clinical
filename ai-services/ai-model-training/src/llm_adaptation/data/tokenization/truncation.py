from __future__ import annotations


def truncate(ids: list[int], max_len: int) -> list[int]:
    if max_len <= 0:
        return []
    return ids[:max_len]
