#!/usr/bin/env python3
import time

from ai_orchestrator.adapter.llm.local import LocalLlm
from ai_orchestrator.domain.message import Message
from ai_orchestrator.domain.model import GenerationConfig


def main() -> None:
    llm = LocalLlm()
    start = time.perf_counter()
    for _ in range(1000):
        llm.generate([Message.user("hi")], GenerationConfig())
    print(f"1000 generate: {(time.perf_counter() - start) * 1000:.1f} ms")


if __name__ == "__main__":
    main()
