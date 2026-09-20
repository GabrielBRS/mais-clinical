#!/usr/bin/env bash
set -euo pipefail
pixi run ai-model-training train --recipe "${1:-recipes/qwen/sft_lora.yaml}" --device cuda
