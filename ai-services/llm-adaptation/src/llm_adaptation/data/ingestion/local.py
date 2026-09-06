from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from llm_adaptation.data import Message, Record


def load_local(path: Path) -> list[Record]:
    if path.is_dir():
        records: list[Record] = []
        for child in sorted(path.iterdir()):
            if child.suffix in {".jsonl", ".json", ".txt"}:
                records.extend(load_local(child))
        return records
    if not path.exists():
        raise FileNotFoundError(path)
    if path.suffix == ".jsonl":
        return [_from_obj(json.loads(line), i) for i, line in enumerate(path.read_text().splitlines()) if line.strip()]
    if path.suffix == ".json":
        payload = json.loads(path.read_text())
        rows = payload if isinstance(payload, list) else payload.get("records", [payload])
        return [_from_obj(row, i) for i, row in enumerate(rows)]
    return [_from_obj({"text": path.read_text()}, 0)]


def _from_obj(obj: dict[str, Any], index: int) -> Record:
    messages = [Message(str(m.get("role", "user")), str(m.get("content", ""))) for m in obj.get("messages") or []]
    return Record(
        id=str(obj.get("id") or f"rec-{index:04d}"),
        text=str(obj.get("text") or ""),
        messages=messages,
        instruction=str(obj.get("instruction") or obj.get("prompt") or ""),
        response=str(obj.get("response") or obj.get("output") or obj.get("completion") or ""),
        chosen=str(obj.get("chosen") or ""),
        rejected=str(obj.get("rejected") or ""),
        meta={k: v for k, v in obj.items() if k not in {
            "id", "text", "messages", "instruction", "prompt", "response",
            "output", "completion", "chosen", "rejected",
        }},
    )
