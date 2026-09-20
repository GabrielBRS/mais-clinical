from __future__ import annotations


def length_ok(text: str, *, min_chars: int = 8, max_chars: int = 32_000) -> bool:
    n = len(text)
    return min_chars <= n <= max_chars
