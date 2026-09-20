#!/usr/bin/env bash
set -euo pipefail
uv run llm-adaptation train --recipe "${1:-recipes/qwen/sft_lora.yaml}"
