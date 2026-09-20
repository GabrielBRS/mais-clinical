from __future__ import annotations

from llm_adaptation.evaluation.metrics import exact_match, token_f1


def run_harness(pairs: list[tuple[str, str]]) -> dict[str, float]:
    if not pairs:
        return {"exact_match": 0.0, "token_f1": 0.0}
    em = sum(exact_match(p, g) for p, g in pairs) / len(pairs)
    f1 = sum(token_f1(p, g) for p, g in pairs) / len(pairs)
    return {"exact_match": em, "token_f1": f1}
