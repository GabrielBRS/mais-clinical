# ai-orchestrator

Terceiro processo da plataforma: agentes, workflows e tools. O core é
**Mojo-first** (`main.mojo` → `./build/agentd`). Os três processos falam
**IPC ACE1** (mesmo framing do `ai-compute-engine` e do `ai-data-engine`).

Durante a migração (Strangler Fig) o legado Python ainda serve HTTP
(FastAPI) e gRPC. Ver `MIGRATION_ANALYSIS.md`.

```text
OS → ./build/agentd → main.mojo → Application → Graph / Agents / RAG
                                              └─ Python só em adapters
```

## Transports

| Canal | Bind default | Estado |
| --- | --- | --- |
| IPC unix socket | `/tmp/ai-orchestrator-python.sock` | ACE1 health 1/2, agent 210, workflow 220 |
| HTTP | `0.0.0.0:8080` | `/health` `/agents/execute` `/workflows/execute` |
| gRPC | `0.0.0.0:50051` | grpc-health (serviço proto depois) |
| Compute IPC | `/tmp/ai-compute-engine.sock` | generate / embed |
| Data IPC | `/tmp/ai-data-engine.sock` | retrieve / rag |

Prefixo de ambiente: `AOR_*`.

## Run (Mojo)

Requer [Pixi](https://pixi.sh/) e Mojo 1.0+.

```bash
pixi install
pixi run test
pixi run run
pixi run build
./build/agentd
```

## Run (legado Python — HTTP / gRPC)

```bash
uv sync
uv run pytest
uv run ai-orchestrator-python
uv run python examples/simple_agent/main.py
```
