from __future__ import annotations


def _ngrams(text: str, n: int = 8) -> set[str]:
    tokens = text.split()
    if len(tokens) < n:
        return {" ".join(tokens)} if tokens else set()
    return {" ".join(tokens[i : i + n]) for i in range(len(tokens) - n + 1)}


def contaminated(candidate: str, held_out: list[str], *, n: int = 8) -> bool:
    cand = _ngrams(candidate, n)
    for text in held_out:
        if cand & _ngrams(text, n):
            return True
    return False
