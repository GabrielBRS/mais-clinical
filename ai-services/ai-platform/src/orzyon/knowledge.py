"""Bounded lexical retrieval over an explicitly curated, read-only Markdown corpus.

This is a retrieval baseline, not vector RAG. IDs never accept filesystem paths.
"""

import hashlib
import re
from pathlib import Path


class Knowledge:
    def __init__(self, root: Path) -> None:
        self.documents: dict[str, dict[str, str]] = {}
        root = root.resolve(strict=True)
        if not root.is_dir():
            raise ValueError("Corpus root must be a directory")
        for path in sorted(root.rglob("*.md")):
            resolved = path.resolve(strict=True)
            if not resolved.is_relative_to(root) or path.is_symlink():
                raise ValueError("Corpus cannot contain links outside its root")
            if len(self.documents) >= 200 or resolved.stat().st_size > 100_000:
                raise ValueError("Corpus limit: 200 documents, 100 KB per document")
            content = resolved.read_text(encoding="utf-8")
            name = path.relative_to(root).as_posix()
            doc_id = hashlib.sha256(name.encode()).hexdigest()[:16]
            self.documents[doc_id] = {
                "id": doc_id,
                "source": name,
                "content": content,
                "version": hashlib.sha256(content.encode()).hexdigest(),
            }

    def retrieve(self, document_id: str) -> dict[str, str]:
        if document_id not in self.documents:
            raise ValueError("Unknown document ID")
        return dict(self.documents[document_id])

    def search(self, query: str, limit: int = 5) -> list[dict[str, str | int]]:
        if not 1 <= len(query) <= 500 or not 1 <= limit <= 10:
            raise ValueError("Query must be 1–500 characters and limit 1–10")
        terms = set(re.findall(r"\w+", query.casefold()))
        hits: list[dict[str, str | int]] = []
        for document in self.documents.values():
            words = set(re.findall(r"\w+", document["content"].casefold()))
            score = len(terms & words)
            if score:
                hits.append(
                    {
                        "id": document["id"],
                        "source": document["source"],
                        "version": document["version"],
                        "score": score,
                        "excerpt": document["content"][:2000],
                    }
                )
        return sorted(hits, key=lambda hit: (-int(hit["score"]), str(hit["id"])))[:limit]
