from __future__ import annotations

import hashlib


def exact_key(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()
