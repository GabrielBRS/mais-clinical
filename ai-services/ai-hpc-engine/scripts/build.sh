#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v pixi >/dev/null 2>&1; then
    export PATH="$HOME/.pixi/bin:$PATH"
fi

mkdir -p build
pixi run mojo build src/main.mojo -o build/ai-compute
