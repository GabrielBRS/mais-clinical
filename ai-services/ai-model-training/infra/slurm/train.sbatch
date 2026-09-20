#!/bin/bash
#SBATCH --job-name=llm-adaptation
uv run llm-adaptation train --recipe recipes/qwen/sft_lora.yaml
