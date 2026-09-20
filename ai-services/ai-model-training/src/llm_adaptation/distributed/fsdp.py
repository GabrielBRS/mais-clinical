from __future__ import annotations


def fsdp_flags(*, sharding: str = "full") -> dict[str, str]:
    return {"strategy": "fsdp", "sharding": sharding}
