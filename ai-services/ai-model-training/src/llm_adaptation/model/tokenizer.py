from __future__ import annotations

from llm_adaptation.data.tokenization import WordTokenizer


def load_tokenizer(texts: list[str] | None = None) -> WordTokenizer:
    return WordTokenizer.fit(texts or ["hello world"])
