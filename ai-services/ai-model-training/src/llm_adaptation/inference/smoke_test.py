from __future__ import annotations

from llm_adaptation.data.tokenization import WordTokenizer
from llm_adaptation.inference.generate import generate
from llm_adaptation.model.loader import DummyModel


def smoke_generate(model: DummyModel, tokenizer: WordTokenizer, prompt: str = "hello") -> str:
    text = generate(model, tokenizer, prompt, max_new_tokens=8, temperature=0.1)
    if not text:
        raise RuntimeError("smoke generate vazio")
    return text
