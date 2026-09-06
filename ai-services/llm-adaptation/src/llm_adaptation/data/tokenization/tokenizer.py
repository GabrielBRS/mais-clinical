from __future__ import annotations

from collections import Counter
from dataclasses import dataclass, field


SPECIALS = ("<pad>", "<unk>", "<bos>", "<eos>")


@dataclass(slots=True)
class WordTokenizer:
    vocab: dict[str, int] = field(default_factory=dict)
    inv: dict[int, str] = field(default_factory=dict)

    @classmethod
    def fit(cls, texts: list[str], *, min_freq: int = 1, max_vocab: int = 8_000) -> WordTokenizer:
        counts = Counter(token for text in texts for token in text.split())
        tokens = [tok for tok, n in counts.most_common(max_vocab) if n >= min_freq]
        vocab = {name: i for i, name in enumerate(SPECIALS)}
        for token in tokens:
            if token not in vocab:
                vocab[token] = len(vocab)
        return cls(vocab, {i: t for t, i in vocab.items()})

    @property
    def pad_id(self) -> int:
        return self.vocab["<pad>"]

    @property
    def unk_id(self) -> int:
        return self.vocab["<unk>"]

    @property
    def bos_id(self) -> int:
        return self.vocab["<bos>"]

    @property
    def eos_id(self) -> int:
        return self.vocab["<eos>"]

    def encode(self, text: str, *, add_special: bool = True) -> list[int]:
        ids = [self.vocab.get(tok, self.unk_id) for tok in text.split()]
        if add_special:
            return [self.bos_id, *ids, self.eos_id]
        return ids

    def decode(self, ids: list[int]) -> str:
        skip = {self.pad_id, self.bos_id, self.eos_id}
        return " ".join(self.inv.get(i, "<unk>") for i in ids if i not in skip)
