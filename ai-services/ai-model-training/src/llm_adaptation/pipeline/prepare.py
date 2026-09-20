from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.data.formatting import format_chat, format_instruction, format_pretraining
from llm_adaptation.data.ingestion import load_records
from llm_adaptation.data.prepare import prepare_records
from llm_adaptation.data.splitting import split_records
from llm_adaptation.data.tokenization import WordTokenizer, truncate
from llm_adaptation.data.validation import summarize, validate_record
from llm_adaptation.recipe import Recipe


def prepare_recipe(recipe: Recipe) -> dict:
    source = recipe.root / str(recipe.data.get("path", "data/sft"))
    kind = str(recipe.data.get("kind", "sft"))
    records = prepare_records(load_records(source))
    records = [r for r in records if not validate_record(r, kind=kind)]
    formatter = {
        "sft": format_chat,
        "instruction": format_instruction,
        "pretraining": format_pretraining,
    }.get(kind, format_chat)
    texts = [formatter(r) for r in records]
    tokenizer = WordTokenizer.fit(texts)
    max_len = int(recipe.model.get("max_seq_len", 128))
    tokenized = [truncate(tokenizer.encode(text), max_len) for text in texts]
    train, val, test = split_records(list(zip(records, texts, tokenized, strict=True)))

    processed = recipe.root / "data" / "processed" / recipe.name
    tokenized_dir = recipe.root / "data" / "tokenized" / recipe.name
    processed.mkdir(parents=True, exist_ok=True)
    tokenized_dir.mkdir(parents=True, exist_ok=True)
    _write_split(processed / "train.jsonl", train)
    _write_split(processed / "validation.jsonl", val)
    _write_split(processed / "test.jsonl", test)
    (tokenized_dir / "train.json").write_text(
        json.dumps([{"id": rec.id, "input_ids": ids, "labels": ids} for rec, _, ids in train])
    )
    (tokenized_dir / "tokenizer.json").write_text(json.dumps(tokenizer.vocab))
    stats = summarize([rec for rec, _, _ in train + val + test])
    return {"records": stats["count"], "train": len(train), "processed": str(processed)}


def _write_split(path: Path, rows: list) -> None:
    lines = []
    for rec, text, _ids in rows:
        lines.append(json.dumps({"id": rec.id, "text": text}))
    path.write_text("\n".join(lines) + ("\n" if lines else ""))
