from __future__ import annotations

import re


_CTRL = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]")
_HTML = re.compile(r"<[^>]+>")


def sanitize(text: str) -> str:
    return _CTRL.sub("", _HTML.sub(" ", text))
