#!/usr/bin/env bash
set -euo pipefail
echo torchrun --nproc_per_node="${NPROC:-8}" -m llm_adaptation train --recipe "${1:-recipes/qwen/sft_full.yaml}"
