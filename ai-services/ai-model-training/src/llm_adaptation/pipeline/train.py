from __future__ import annotations

import json
from pathlib import Path

from llm_adaptation.data import TokenizedExample
from llm_adaptation.data.formatting import format_chat
from llm_adaptation.data.ingestion import load_records
from llm_adaptation.data.prepare import prepare_records
from llm_adaptation.data.tokenization import WordTokenizer, truncate
from llm_adaptation.experiment import Run, Tracker
from llm_adaptation.model import ModelConfig, load_model
from llm_adaptation.recipe import Recipe
from llm_adaptation.training import TrainConfig, train
from llm_adaptation.training.sft import SFTTrainer


def _examples(recipe: Recipe) -> list[TokenizedExample]:
    tokenized = recipe.root / "data" / "tokenized" / recipe.name / "train.json"
    if tokenized.exists():
        rows = json.loads(tokenized.read_text())
        return [TokenizedExample(r["id"], r["input_ids"], r["labels"]) for r in rows]
    source = recipe.root / str(recipe.data.get("path", "data/sft"))
    records = prepare_records(load_records(source))
    texts = [format_chat(r) for r in records]
    tokenizer = WordTokenizer.fit(texts)
    max_len = int(recipe.model.get("max_seq_len", 128))
    return [
        TokenizedExample(r.id, ids, ids)
        for r, ids in ((r, truncate(tokenizer.encode(t), max_len)) for r, t in zip(records, texts, strict=True))
    ]


def train_recipe(recipe: Recipe) -> dict:
    examples = _examples(recipe)
    if not examples:
        raise RuntimeError("nenhum exemplo para treinar — rode prepare")
    output = recipe.root / "artifacts" / "checkpoints" / recipe.name
    config = TrainConfig.from_recipe(recipe.training, output)
    model = load_model(ModelConfig.from_dict(recipe.model))
    if recipe.method in {"sft", "full"} or recipe.adapter in {"lora", "qlora", "none"}:
        result = SFTTrainer().run(model, examples, config)
    else:
        result = train(model, examples, config)
    run = Run.start(recipe.name)
    run.metrics = result.metrics
    Tracker(recipe.root / "artifacts" / "logs" / "runs.jsonl").log(run)
    if result.adapter in {"lora", "qlora"}:
        adapter_dir = recipe.root / "artifacts" / "adapters" / recipe.name
        adapter_dir.mkdir(parents=True, exist_ok=True)
        (adapter_dir / "adapter.json").write_text(
            json.dumps({"kind": result.adapter, "checkpoint": str(result.checkpoint)}, indent=2)
        )
    return {
        "checkpoint": str(result.checkpoint),
        "loss": result.metrics["loss"],
        "adapter": result.adapter,
        "run": run.id,
    }
