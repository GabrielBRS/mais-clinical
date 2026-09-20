#!/usr/bin/env bash
set -euo pipefail
echo deepspeed scripts/training/train_full.py --deepspeed configs/distributed/deepspeed_zero2.yaml
