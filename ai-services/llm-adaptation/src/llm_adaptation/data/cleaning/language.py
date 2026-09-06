from __future__ import annotations


def latin_ratio(text: str) -> float:
    letters = [ch for ch in text if ch.isalpha()]
    if not letters:
        return 0.0
    latin = sum(1 for ch in letters if ord(ch) < 0x250)
    return latin / len(letters)
