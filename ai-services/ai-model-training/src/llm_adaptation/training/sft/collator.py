from __future__ import annotations

from llm_adaptation.data import TokenizedExample


def pad_batch(examples: list[TokenizedExample], pad_id: int) -> tuple[list[list[int]], list[list[int]]]:
    width = max((len(ex.input_ids) for ex in examples), default=0)
    inputs: list[list[int]] = []
    labels: list[list[int]] = []
    for example in examples:
        pad = width - len(example.input_ids)
        inputs.append(example.input_ids + [pad_id] * pad)
        labels.append(example.labels + [-100] * pad)
    return inputs, labels
