from __future__ import annotations


def resize_box(w: int, h: int, target: int) -> tuple[int, int]:
    scale = target / max(w, h)
    return max(1, int(w * scale)), max(1, int(h * scale))
