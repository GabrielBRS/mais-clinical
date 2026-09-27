"""Deterministic lexical retrieval evaluation; no LLM judge or invented relevance labels."""

import argparse
import json
import math
from datetime import UTC, datetime
from pathlib import Path

from orzyon.experiments import metadata
from orzyon.knowledge import Knowledge


def evaluate(corpus: Knowledge, cases: list[dict], k: int) -> dict:
    if k < 1 or k > 10 or not cases:
        raise ValueError("Use 1 <= k <= 10 and a nonempty dataset")
    rows = []
    for case in cases:
        relevant = set(case["relevant_sources"])
        if not relevant:
            raise ValueError("Each case needs human-reviewed relevant_sources")
        found = [hit["source"] for hit in corpus.search(case["query"], k)]
        hits = [int(source in relevant) for source in found]
        dcg = sum(hit / math.log2(index + 2) for index, hit in enumerate(hits))
        ideal = sum(1 / math.log2(index + 2) for index in range(min(k, len(relevant))))
        rows.append(
            {
                "id": case["id"],
                "precision_at_k": sum(hits) / k,
                "recall_at_k": sum(hits) / len(relevant),
                "reciprocal_rank": next((1 / (i + 1) for i, h in enumerate(hits) if h), 0),
                "ndcg_at_k": dcg / ideal,
            }
        )
    return {
        "timestamp": datetime.now(UTC).isoformat(),
        "k": k,
        "cases": rows,
        "macro": {
            metric: sum(row[metric] for row in rows) / len(rows)
            for metric in ("precision_at_k", "recall_at_k", "reciprocal_rank", "ndcg_at_k")
        },
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dataset", type=Path)
    parser.add_argument("--corpus", type=Path, default=Path("knowledge"))
    parser.add_argument("--k", type=int, default=3)
    args = parser.parse_args()
    result = evaluate(Knowledge(args.corpus), json.loads(args.dataset.read_text()), args.k)
    result["experiment"] = metadata(args.dataset)
    result["corpus_versions"] = {
        doc["source"]: doc["version"] for doc in Knowledge(args.corpus).documents.values()
    }
    print(json.dumps(result, indent=2))
