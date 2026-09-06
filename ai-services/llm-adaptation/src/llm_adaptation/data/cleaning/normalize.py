from __future__ import annotations

import re
import unicodedata


_WS = re.compile(r"\s+")


def normalize(text: str) -> str:
    folded = unicodedata.normalize("NFC", text).replace("\r\n", "\n").replace("\r", "\n")
    return _WS.sub(" ", folded).strip()
