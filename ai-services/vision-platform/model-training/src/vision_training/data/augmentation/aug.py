from __future__ import annotations


def hflip(pixels: list[int], width: int) -> list[int]:
    rows = [pixels[i : i + width] for i in range(0, len(pixels), width)]
    return [v for row in rows for v in reversed(row)]
