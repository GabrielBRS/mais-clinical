#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v pixi >/dev/null 2>&1; then
    export PATH="$HOME/.pixi/bin:$PATH"
fi

pixi run mojo run -I src tests/test_core.mojo
