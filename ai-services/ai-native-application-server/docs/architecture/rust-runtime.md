# Rust Application Server — migration phase 1

The Rust runtime is the only public process of the AI Native Application
Server. During phase 1 it exposes lifecycle probes, a traditional CRUD slice
and agentic use cases backed by the internal agent runtime port, while Python
and Mojo remain behavioral baselines.

```text
client
  -> runtime-rust (only public ingress)
       -> traditional use case -> database/integration -> response
       -> agentic use case -> mojo-agent-runtime -> response
```

## Current boundary

`runtime-rust` currently owns:

- environment configuration with the `AOR_` prefix;
- structured JSON logs and HTTP tracing;
- liveness and readiness endpoints;
- graceful SIGINT/SIGTERM shutdown;
- generated Rust clients and servers for the versioned Protobuf contracts;
- the internal `AgentRuntime` port used only by explicitly agentic use cases;
- an HTTP adapter to the private Mojo baseline;
- an in-memory records slice proving traditional requests never call Mojo;
- a self-contained container health check.

No agent or workflow behavior has been cut over yet. Those capabilities remain
in the existing baselines until the Mojo agent runtime proves parity. Business
domain, persistence and traditional application flows will migrate to Rust.

## Ingress invariant

Rust is the only process reachable by clients. Mojo has no public route, public
port or client-facing credentials. Rust authenticates and validates a request,
executes the business use case and invokes Mojo only when that use case is
explicitly agentic. Mojo returns an internal result; Rust maps it to the public
response.

Traditional use cases do not depend on the `AgentRuntime` port. Consequently,
Rust global readiness must not fail merely because Mojo is sleeping or
temporarily unavailable. Only an agentic invocation reports that dependency
failure.

## Endpoints

- `GET /health`
- `GET /health/live`
- `GET /health/ready`

Readiness starts as false and becomes true only after the TCP listener binds.
It returns to false when graceful shutdown begins. Mojo availability will be
reported separately for agentic capabilities and will not gate traditional
backend readiness.

## Local commands

```bash
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
cargo run -p ai-native-runtime
docker build -f runtime-rust/Dockerfile -t orzyon/ai-native-runtime:0.1.0 .
```

The container listens on port `8080` and runs as an unprivileged user.
