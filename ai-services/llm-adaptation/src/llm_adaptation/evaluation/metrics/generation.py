from __future__ import annotations


def token_f1(pred: str, gold: str) -> float:
    pred_t = pred.split()
    gold_t = gold.split()
    if not pred_t or not gold_t:
        return 0.0
    overlap = len(set(pred_t) & set(gold_t))
    precision = overlap / len(set(pred_t))
    recall = overlap / len(set(gold_t))
    if precision + recall == 0:
        return 0.0
    return 2 * precision * recall / (precision + recall)
