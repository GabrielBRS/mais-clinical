#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export ADE_APP_ENV="${ADE_APP_ENV:-development}"
export ADE_HTTP_BIND="${ADE_HTTP_BIND:-0.0.0.0:8082}"
export ADE_GRPC_BIND="${ADE_GRPC_BIND:-0.0.0.0:50053}"
export ADE_IPC_PATH="${ADE_IPC_PATH:-/tmp/ai-data-engine.sock}"
cargo run
