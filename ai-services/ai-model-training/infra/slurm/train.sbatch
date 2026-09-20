#!/bin/bash
#SBATCH --job-name=llm-adaptation
pixi run ai-model-training train --recipe recipes/qwen/sft_lora.yaml --device cuda
