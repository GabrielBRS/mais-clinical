from __future__ import annotations

from collections import Counter


def quality_ok(text: str, *, min_chars: int = 8, max_repeat: float = 0.55) -> bool:
    if len(text) < min_chars:
        return False
    tokens = text.split()
    if not tokens:
        return False
    top = Counter(tokens).most_common(1)[0][1]
    return (top / len(tokens)) <= max_repeat
