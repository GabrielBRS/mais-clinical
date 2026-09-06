from __future__ import annotations

_BLOCK = ("kill yourself", "hate speech", "slur-placeholder")


def toxicity_hit(text: str) -> bool:
    lowered = text.lower()
    return any(term in lowered for term in _BLOCK)
