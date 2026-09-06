from __future__ import annotations

from llm_adaptation.data.tokenization import WordTokenizer
from llm_adaptation.inference.sampling import sample_id
from llm_adaptation.model.loader import DummyModel


def generate(
    model: DummyModel,
    tokenizer: WordTokenizer,
    prompt: str,
    *,
    max_new_tokens: int = 16,
    temperature: float = 0.8,
) -> str:
    ids = tokenizer.encode(prompt)
    pool = model.weights or {tokenizer.unk_id: 0.0, tokenizer.eos_id: 0.1}
    if model.adapter:
        deltas = model.adapter.get("deltas", {})
        merged = dict(pool)
        for key, value in deltas.items():  # type: ignore[union-attr]
            merged[int(key)] = merged.get(int(key), 0.0) + float(value)
        pool = merged
    for _ in range(max_new_tokens):
        nxt = sample_id(pool, temperature=temperature)
        ids.append(nxt)
        if nxt == tokenizer.eos_id:
            break
    return tokenizer.decode(ids)
