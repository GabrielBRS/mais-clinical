"""Adaptação de LLMs — prepare → train → evaluate → export → publish."""

from __future__ import annotations

__version__ = "0.1.0"


def main() -> None:
    from llm_adaptation.pipeline import main as pipeline_main

    pipeline_main()
