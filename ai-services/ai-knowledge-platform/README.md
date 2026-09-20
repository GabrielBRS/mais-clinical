# ai-data-engine

Segundo processo da plataforma: ingestão, retrieval, ranking e packing de
contexto RAG. Os três processos falam **IPC ACE1** (mesmo framing do
`ai-compute-engine`). HTTP (Axum) e gRPC (Tonic) expõem o mesmo contrato
em `proto/`.

## Transports

| Canal | Bind default | Estado |
| --- | --- | --- |
| IPC unix socket | `/tmp/ai-data-engine.sock` | ACE1 + retrieve/ingest/rag |
| HTTP | `0.0.0.0:8082` | `/health` `/retrieve` `/rag` `/ingest` |
| gRPC | `0.0.0.0:50053` | tonic-health (serviço proto depois) |

Cliente do compute-engine: `ADE_COMPUTE_IPC_PATH` (`/tmp/ai-compute-engine.sock`).
Health (tipos 1/2) é compartilhado entre os processos.

## Run

```bash
./scripts/dev.sh
cargo test
cargo run --example rag_query
```
