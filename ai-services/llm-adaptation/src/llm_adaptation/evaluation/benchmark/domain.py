from __future__ import annotations

DOMAINS = ("general", "code", "math", "safety")


def domain_for(name: str) -> str:
    key = name.lower()
    for domain in DOMAINS:
        if domain in key:
            return domain
    return "general"
