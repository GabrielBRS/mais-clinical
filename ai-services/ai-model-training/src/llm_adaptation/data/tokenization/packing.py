from __future__ import annotations


def pack(sequences: list[list[int]], *, max_len: int, eos_id: int) -> list[list[int]]:
    packed: list[list[int]] = []
    current: list[int] = []
    for seq in sequences:
        piece = list(seq)
        if piece and piece[-1] != eos_id:
            piece.append(eos_id)
        if len(piece) > max_len:
            piece = piece[:max_len]
        if current and len(current) + len(piece) > max_len:
            packed.append(current)
            current = []
        current.extend(piece)
    if current:
        packed.append(current)
    return packed
