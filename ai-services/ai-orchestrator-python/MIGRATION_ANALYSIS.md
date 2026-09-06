# Análise de migração — Mojo-first

Inventário da Fase 0. Este documento descreve a arquitetura **atual**
(Python hexagonal), o destino **Mojo-first**, e o plano incremental
(Strangler Fig). Python permanece executável e testável até cada
módulo migrado ter paridade observável.

## 1. Arquitetura atual

O processo é o terceiro da plataforma (`orchestrator`), ao lado de
`ai-compute-engine` e `ai-data-engine`. Os três falam **IPC ACE1**.

```text
OS
 ↓
python -m ai_orchestrator / uv run ai-orchestrator-python
 ↓
asyncio.Application.serve()
 ├─ FastAPI / uvicorn          :8080
 ├─ grpc.aio                   :50051
 └─ ACE1 unix socket           /tmp/ai-orchestrator-python.sock
        │
        ├─ AceClient → /tmp/ai-compute-engine.sock   (generate / embed)
        └─ AceClient → /tmp/ai-data-engine.sock      (retrieve / rag)
```

Hexagonal já existente:

```text
domain → usecase → port ← adapter
                 ↑
         composition_root (único lugar que escolhe adapters)
                 ↑
         transport (HTTP / gRPC / IPC)
```

O composition root (`AppContainer.build`) é o único ponto que instancia
adapters. Domain e use cases não conhecem FastAPI, gRPC ou ACE1.

**Problema arquitetural relativo ao objetivo:** Python é o runtime, o
orquestrador e o dono do `main()`. Mesmo com hexagonal correto, o
sistema é *Python que orquestra*, não *Mojo que ocasionalmente usa
Python*.

Não há LangGraph, LangChain, nem outro framework agentic de terceiro.
O grafo é um DAG próprio (`Graph` / `Node` / `Edge`) percorrido em
`ExecuteWorkflowUseCase`. Isso **ajuda** a migração: não precisamos
estrangular um framework externo, só o runtime Python.

## 2. Entry points atuais

| Entrypoint | Linguagem | Papel | Destino |
| --- | --- | --- | --- |
| `src/ai_orchestrator/__init__.py` → `main()` | Python | script `ai-orchestrator-python` | **REMOVE** depois que `./build/agentd` servir |
| `bootstrap/application.py` → `run()` / `Application.serve()` | Python | sobe HTTP + gRPC + IPC no mesmo loop asyncio | **MIGRATE_TO_MOJO** (lifecycle); transports Python atrás de port |
| `examples/*/main.py` | Python | clientes de demonstração | **REFACTOR** para clientes ACE1; HTTP pode ficar em Python |
| `scripts/dev.py`, `smoke_test.py`, `benchmark.py` | Python | DX | **KEEP_PYTHON_TEMPORARILY** |
| `src/main.mojo` | — | não existia | **criar** (Fase 1) |

Direção alvo:

```text
OS → ./build/agentd → main.mojo → Application → Agent / Graph / State
                                              └─ Python só em adapters
```

## 3. Dependências

### 3.1 Declaradas (`pyproject.toml`)

| Pacote | Uso real hoje | Destino |
| --- | --- | --- |
| `fastapi`, `uvicorn` | HTTP server + TestClient | **PYTHON_ADAPTER** — sem servidor HTTP maduro em Mojo |
| `grpcio`, `grpcio-health-checking`, `protobuf` | gRPC health; stubs gerados | **PYTHON_ADAPTER** |
| `pydantic-settings` | `Settings` via `AOR_*` | **MIGRATE_TO_MOJO** (struct + env); pydantic some |
| `pytest`, `pytest-asyncio`, `httpx` | testes Python | permanecem enquanto houver superfície Python |
| `grpcio-tools` | geração de proto | **KEEP_PYTHON_TEMPORARILY** |

### 3.2 Importadas mas **não** ligadas (sem SDK no lock)

OpenAI, Anthropic, Redis, Milvus, NATS, Kafka, Fjall, redb, clients
C++/Rust: adapters existem como **stubs in-process**. Nenhum SDK
desses está em `dependencies`. Não há justificativa para mantê-los
em Python *agora* — a lógica atual é dicionário / hash / no-op.

Quando (e se) o vendor real for ligado:

| Vendor | Justificativa Python | Alternativa Mojo |
| --- | --- | --- |
| OpenAI / Anthropic SDK | SDK oficial, auth, retries, streaming | HTTP nativo depois; até lá **PYTHON_ADAPTER** |
| Redis / Milvus | clients maduros | **PYTHON_ADAPTER** ou IPC para data-engine |
| NATS / Kafka | clients maduros | **PYTHON_ADAPTER** |
| FastAPI / grpcio | ecossistema de serving | **PYTHON_ADAPTER** até existir serving nativo |
| `json` / `socket` / `os` / `tomllib` | stdlib | `socket`/`os` via CPython embutido (padrão do `vision-inference-engine`); ACE1 e JSON de domínio em Mojo |

## 4. O que o sistema realmente faz hoje

Caminho quente (o que os testes exercitam):

1. `ExecuteAgentUseCase`: localiza `Agent`, opcionalmente `vector.search`,
   monta `Message` system+user, chama `llm.generate`.
2. `ExecuteWorkflowUseCase`: `graph.start()` → enquanto não visitado,
   se `retrieve` busca top-3 e prefixa contexto; se `generate` chama LLM
   e retorna. Grafo default: `retrieve → generate`.
3. `LocalLlm.generate` devolve `"[local] {último texto}"`.
4. `LocalLlm.embed` / `MilvusVector.search`: embedding FNV-1a em 32 dims
   + produto interno + top-k (índice em memória).
5. ACE1: framing 20 bytes little-endian, magic `ACE1`.
6. HTTP/gRPC/IPC são três fachadas do mesmo use case.

Tudo isso é domínio + compute + protocolo. **Nada disso precisa de
Python.** Python só se justifica para FastAPI, gRPC e SDKs de vendor
quando forem de fato ligados.

## 5. Inventário de módulos

Classificação:

| Destino | Significado |
| --- | --- |
| `MIGRATE_TO_MOJO` | responsabilidade do core; implementar em Mojo |
| `PYTHON_ADAPTER` | permanece Python atrás de port Mojo |
| `KEEP_PYTHON_TEMPORARILY` | Python por enquanto; reavaliar |
| `REMOVE` | some depois da paridade |
| `REFACTOR` | muda de lugar / contrato, não some |
| `NEEDS_INVESTIGATION` | depende de decisão externa (data-engine, vendor) |

### 5.1 Bootstrap / config / observabilidade

| módulo atual | responsabilidade | linguagem | destino | dependências | motivo |
| --- | --- | --- | --- | --- | --- |
| `ai_orchestrator/__init__.py` | `main()` Python | Python | REMOVE | bootstrap | entrypoint deve ser `main.mojo` |
| `bootstrap/application.py` | lifecycle, serve HTTP/gRPC/IPC, dispatch ACE1 | Python | MIGRATE_TO_MOJO + PYTHON_ADAPTER | uvicorn, grpc, socket, usecases | Mojo dono do processo; FastAPI/gRPC atrás de `TransportPort` |
| `bootstrap/lifecycle.py` | shutdown uvicorn/grpc/tasks | Python | MIGRATE_TO_MOJO | asyncio | lifecycle é ownership Mojo |
| `bootstrap/composition_root.py` | wiring ports→adapters | Python | MIGRATE_TO_MOJO | adapters | composition root Mojo escolhe providers |
| `bootstrap/dependencies.py` | factory LLM/storage, grafo e agente default | Python | MIGRATE_TO_MOJO | domain | regras de wiring são aplicação |
| `config/settings.py` | `AOR_*`, hosts, ports, provider | Python | MIGRATE_TO_MOJO | pydantic-settings | struct `Settings`; env via `os` embutido |
| `config/loader.py` | TOML por ambiente | Python | KEEP_PYTHON_TEMPORARILY | tomllib | parser TOML ainda mais barato via CPython |
| `config/environment.py` | enum de env | Python | MIGRATE_TO_MOJO | — | enum trivial |
| `observability/logging.py` | `basicConfig` | Python | KEEP_PYTHON_TEMPORARILY | logging | logging estruturado / Langfuse depois |
| `observability/tracing.py` | no-op `span` | Python | MIGRATE_TO_MOJO | — | stub; depois port `TelemetryProvider` |
| `observability/metrics.py` | no-op `increment` | Python | MIGRATE_TO_MOJO | — | idem |
| `observability/telemetry.py` | `boot` | Python | REFACTOR | logging | vira adapter de telemetria |

### 5.2 Domain

Tudo `MIGRATE_TO_MOJO`. Sem I/O, sem vendor, tipos explícitos.

| módulo atual | responsabilidade | destino | motivo |
| --- | --- | --- | --- |
| `domain/agent/*` | `Agent`, `AgentId`, `Capability`, `Policy`, erros | MIGRATE_TO_MOJO | contrato de agente |
| `domain/message/*` | `Message`, `Role`, `Content` | MIGRATE_TO_MOJO | estado conversacional |
| `domain/conversation/*` | `Conversation`, `ConversationId`, `ConversationState` | MIGRATE_TO_MOJO | memória de diálogo |
| `domain/execution/*` | `Execution`, `ExecutionId`, `ExecutionStatus`, `ExecutionResult` | MIGRATE_TO_MOJO | state machine |
| `domain/workflow/graph.py` | DAG, `start`, `successors` | MIGRATE_TO_MOJO | coração do grafo |
| `domain/workflow/node.py` | `id`, `kind`, `label` | MIGRATE_TO_MOJO | |
| `domain/workflow/edge.py` | `source`, `target` | MIGRATE_TO_MOJO | |
| `domain/workflow/transition.py` | transição com condição (ainda não usada no executor) | MIGRATE_TO_MOJO | routing condicional futuro |
| `domain/tool/*` | `Tool`, `ToolSchema`, `ToolCall`, `ToolResult` | MIGRATE_TO_MOJO | registry nativo |
| `domain/model/*` | `Model`, `ModelId`, `Provider`, `GenerationConfig` | MIGRATE_TO_MOJO | |

### 5.3 Use cases (application)

| módulo atual | responsabilidade | destino | motivo |
| --- | --- | --- | --- |
| `usecase/execute_agent/*` | orquestra retrieve + generate | MIGRATE_TO_MOJO | Python não pode decidir o agente |
| `usecase/execute_workflow/*` | walk do grafo | MIGRATE_TO_MOJO | graph execution |
| `usecase/generate_response/*` | chama `GeneratePort` | MIGRATE_TO_MOJO | |
| `usecase/retrieve_context/*` | chama `VectorSearchPort` | MIGRATE_TO_MOJO | |
| `usecase/execute_tool/*` | `echo` / unknown | MIGRATE_TO_MOJO | tool dispatch |

### 5.4 Orchestration / runtime

| módulo atual | responsabilidade | destino | motivo |
| --- | --- | --- | --- |
| `orchestration/executor/agent_executor.py` | delega ao use case | MIGRATE_TO_MOJO | wrapper fino |
| `orchestration/executor/workflow_executor.py` | delega ao use case | MIGRATE_TO_MOJO | |
| `orchestration/routing/router.py` | id explícito vs semântico | MIGRATE_TO_MOJO | routing |
| `orchestration/routing/deterministic.py` | `id in available` | MIGRATE_TO_MOJO | |
| `orchestration/routing/semantic.py` | retorna `available[0]` | MIGRATE_TO_MOJO | stub; depois embeddings Mojo |
| `orchestration/state/machine.py` | `pending/running/succeeded/failed` | MIGRATE_TO_MOJO | state machine |
| `orchestration/state/store.py` | dict in-memory | MIGRATE_TO_MOJO | |
| `orchestration/runtime/runtime.py` | scheduler + context | MIGRATE_TO_MOJO | stubs |
| `orchestration/runtime/scheduler.py` | no-op enqueue | MIGRATE_TO_MOJO | |
| `orchestration/runtime/context.py` | `request_id`, `cancelled` | MIGRATE_TO_MOJO | |
| `orchestration/runtime/cancellation.py` | token | MIGRATE_TO_MOJO | |

### 5.5 Ports

| módulo atual | responsabilidade | destino | motivo |
| --- | --- | --- | --- |
| `port/llm/generate.py` | `generate(messages, config)` | MIGRATE_TO_MOJO | trait `LLMProvider` |
| `port/llm/stream.py` | stream | MIGRATE_TO_MOJO | trait |
| `port/llm/embed.py` | embed | MIGRATE_TO_MOJO | trait `EmbeddingProvider` |
| `port/vector/search.py` | search | MIGRATE_TO_MOJO | trait `VectorStore` |
| `port/vector/index.py` | index | MIGRATE_TO_MOJO | |
| `port/memory/load.py` / `save.py` | conversas | MIGRATE_TO_MOJO | |
| `port/storage/{load,save,delete}.py` | KV | MIGRATE_TO_MOJO | |
| `port/messaging/{publish,consume}.py` | pub/sub | MIGRATE_TO_MOJO | |
| `port/rpc/inference.py` | generate remoto | MIGRATE_TO_MOJO | ACE1 client nativo |
| `port/rpc/retrieval.py` | retrieve remoto | MIGRATE_TO_MOJO | ACE1 client nativo |
| `port/native/reranker.py` | rerank | MIGRATE_TO_MOJO | compute |
| `port/native/tokenizer.py` | tokenize | MIGRATE_TO_MOJO | |

Nenhum port atual importa SDK. A migração é 1:1 para traits Mojo.

### 5.6 Adapters — compute / in-process (migrar)

| módulo atual | responsabilidade | destino | dependências | motivo |
| --- | --- | --- | --- | --- |
| `adapter/llm/local/adapter.py` | generate determinístico + hash embed | MIGRATE_TO_MOJO | — | compute local; hot path |
| `adapter/vector/milvus/adapter.py` | índice RAM + cosine + top-k | MIGRATE_TO_MOJO | hash embed | **não é Milvus**; é compute |
| `adapter/vector/milvus/mapper.py` | identidade | MIGRATE_TO_MOJO | — | |
| `adapter/vector/milvus/client.py` | stub vazio | REMOVE ou PYTHON_ADAPTER | — | client real só quando Milvus existir |
| `adapter/memory/redis/adapter.py` | dict de `Conversation` | MIGRATE_TO_MOJO | domain | **não é Redis** |
| `adapter/memory/redis/client.py` | stub | PYTHON_ADAPTER | — | quando Redis for ligado |
| `adapter/storage/fjall/adapter.py` | dict `[str, bytes]` | MIGRATE_TO_MOJO | — | **não é Fjall** |
| `adapter/storage/redb/adapter.py` | alias de Fjall | MIGRATE_TO_MOJO | — | idem |
| `adapter/native/rust/adapter.py` | rerank 0.0, encode bytes | MIGRATE_TO_MOJO | — | vira `compute/rerank` |
| `adapter/native/cpp/adapter.py` | stub vazio | REMOVE | — | sem comportamento |
| `adapter/llm/openai/mapper.py` | `Message` → dict role/content | MIGRATE_TO_MOJO | domain | transformação de domínio |
| `adapter/ipc/unix_socket/protocol.py` | ACE1 encode/decode | MIGRATE_TO_MOJO | struct | protocolo da plataforma |
| `adapter/ipc/unix_socket/connection.py` | read/write frames | MIGRATE_TO_MOJO + Python socket | socket | framing Mojo; `socket` via CPython (padrão vision) |
| `adapter/ipc/unix_socket/client.py` | call/health | MIGRATE_TO_MOJO | protocol | |
| `adapter/rpc/grpc/inference_client.py` | ACE1 generate + fallback local | MIGRATE_TO_MOJO | AceClient | já é IPC, não gRPC |
| `adapter/rpc/grpc/retrieval_client.py` | ACE1 retrieve + JSON | MIGRATE_TO_MOJO | AceClient, json | JSON payload: parse coarse-grained |

### 5.7 Adapters — vendors / serving (Python atrás de port)

| módulo atual | responsabilidade | destino | dependências | motivo |
| --- | --- | --- | --- | --- |
| `adapter/llm/openai/adapter.py` | `RuntimeError` "nao ligado" | PYTHON_ADAPTER | SDK futuro | só quando ligar o SDK |
| `adapter/llm/openai/client.py` | stub | PYTHON_ADAPTER | openai | |
| `adapter/llm/anthropic/*` | stub | PYTHON_ADAPTER | anthropic | |
| `adapter/messaging/nats/adapter.py` | no-op | PYTHON_ADAPTER | nats | |
| `adapter/messaging/kafka/*` | stub | PYTHON_ADAPTER | kafka | |
| `adapter/rpc/jsonrpc/client.py` | stub | KEEP_PYTHON_TEMPORARILY | — | sem uso |
| `adapter/ipc/shared_memory/*` | stubs | NEEDS_INVESTIGATION | — | vision marca SHM como indisponível; só se medir necessidade |
| `transport/http/**` | FastAPI, middleware, DTO | PYTHON_ADAPTER | fastapi | serving maduro só em Python |
| `transport/grpc/**` | grpc.aio + health | PYTHON_ADAPTER | grpcio | |
| `generated/proto/**` | stubs protobuf | PYTHON_ADAPTER | protobuf | gerado; some se gRPC nativo surgir |
| `observability` Langfuse/OTel (ainda não existe) | — | PYTHON_ADAPTER | — | quando existir |

### 5.8 RAG / compute (hoje espalhado)

Não há pacote `rag/`. O pipeline está implícito:

```text
texto → _hash_embed → índice RAM → cosine → sort → top-k → prefixo "Context:"
```

| etapa | código atual | destino | motivo |
| --- | --- | --- | --- |
| chunking | ausente | MIGRATE_TO_MOJO | texto, CPU |
| normalização / tokenize | `str.lower().split()` | MIGRATE_TO_MOJO | |
| embedding local | `_hash_embed` | MIGRATE_TO_MOJO | FNV-1a + L2; SIMD depois |
| embedding vendor | não ligado | PYTHON_ADAPTER | |
| index / retrieve | `MilvusVector` | MIGRATE_TO_MOJO | |
| similarity / top-k | list sort | MIGRATE_TO_MOJO | `compute/` |
| rerank | `RustNative` zeros | MIGRATE_TO_MOJO | |
| retrieve remoto (data-engine) | `RetrievalClient` ACE1 | MIGRATE_TO_MOJO | protocolo nativo |
| generate remoto (compute-engine) | `InferenceClient` ACE1 | MIGRATE_TO_MOJO | |

CPU-bound: hash embed, cosine, top-k, walk de grafo pequeno.
I/O-bound: HTTP, gRPC, unix socket, futuros SDKs.
GPU: nenhum no orchestrator (fica no compute-engine).

### 5.9 Infra, testes, DX

| módulo atual | responsabilidade | destino | motivo |
| --- | --- | --- | --- |
| `tests/unit/domain/test_graph.py` | start/successors | REFACTOR | espelhar em `tests/mojo`; Python até remover domínio |
| `tests/unit/usecase/test_execute_agent.py` | `"[local] hello"`, `exe-` | REFACTOR | contrato observável |
| `tests/unit/orchestration/test_executor.py` | steps retrieve→generate | REFACTOR | |
| `tests/unit/adapter/test_ipc_protocol.py` | ACE1 roundtrip | REFACTOR | |
| `tests/e2e/*`, `tests/integration/http/*` | FastAPI | KEEP_PYTHON_TEMPORARILY | enquanto HTTP for Python |
| `tests/integration/grpc/*` | bind | KEEP_PYTHON_TEMPORARILY | |
| `tests/integration/ipc/*` | ACE1 | REFACTOR | cliente Mojo + legado |
| `tests/contract/*` | ports / grpc | KEEP_PYTHON_TEMPORARILY | |
| `tests/performance/*` | latency/throughput | REFACTOR | benches Mojo depois |
| `examples/*` | clientes | REFACTOR | |
| `scripts/*` | proto, smoke, bench | KEEP_PYTHON_TEMPORARILY | |
| `resources/prompts/*`, `resources/schemas/*` | assets | KEEP (dados) | Mojo lê arquivos |
| `config/*.toml` | overrides | KEEP | loader Python temporário |
| `proto/` (se existir fora de generated) | contrato gRPC | KEEP | |
| `docs/**` | ADR hexagonal | REFACTOR | atualizar para Mojo-first |
| `benchmarks/**` | benches Python | REFACTOR | |
| `pyproject.toml` | pacote Python | REFACTOR | vira só compatibility |
| `pixi.toml` | — | criar | toolchain Mojo, igual aos irmãos |

## 6. Arquitetura alvo (Mojo-first)

Alinhada ao `ai-compute-engine` e ao `vision-inference-engine`
(mesmo monorepo: `def`, `__init__.mojo`, `raises OrchestratorError`,
pixi, ACE1).

```text
                 main.mojo
                    │
                    ▼
              app.Application          ← lifecycle, config, wiring
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
   agents/       graph/        memory/
   supervisor    executor      checkpoint
       │
       ├─ rag/        chunk → embed → retrieve → topk → rerank
       ├─ tools/      registry + echo
       ├─ compute/    hash embed, cosine, top-k (CPU/SIMD)
       └─ ipc/        ACE1 nativo
                    │
                    │ somente adapters
                    ▼
              ports/ (traits)
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
   adapters/local        adapters/python
   LocalLlm              bridge.mojo → CPython
   InMemoryVector          ├─ FastAPI / uvicorn
                           ├─ grpcio
                           ├─ OpenAI / Anthropic (quando ligados)
                           └─ Redis / Milvus / NATS (quando ligados)
```

Regra de dependência:

```text
domain  ←  app / graph / agents / rag / tools
                ↑
              ports
                ↑
            adapters     (único lugar que importa Python)
```

Python como plugin removível: se `adapters/python` for desligado,
`LocalLlm` + índice em memória + ACE1 continuam a executar o caminho
que os testes de domínio já cobrem.

### 6.1 Layout desta migração

```text
src/main.mojo
src/app/{application,lifecycle,config}.mojo
src/domain/{agent,message,state,context,execution,errors,status,model,tool}.mojo
src/graph/{graph,node,edge,router,executor}.mojo
src/agents/{registry,supervisor}.mojo
src/rag/{pipeline,chunker,retriever,reranker,embeddings}.mojo
src/memory/memory.mojo
src/tools/registry.mojo
src/compute/{kernels,similarity,topk}.mojo
src/ports/{llm_provider,embedding_provider,vector_store,telemetry_provider}.mojo
src/adapters/local/{llm,vector}.mojo
src/adapters/python/bridge.mojo
src/ipc/protocol.mojo

python/compatibility/          ← Fase 4 (HTTP/gRPC/SDKs)
src/ai_orchestrator/           ← legado Python (strangler, ainda testável)

tests/mojo/
tests/                         ← pytest legado
```

Nomes seguem o pedido, com o pacote Mojo em `src/` (como os irmãos)
e o Python legado intacto em `src/ai_orchestrator/` até a Fase 6.

## 7. Plano incremental

Cada fase: implementar → testes de paridade → só então apagar Python.

### Fase 0 — Inventory (este documento)

Entregue. Nenhuma responsabilidade de domínio muda.

### Fase 1 — Bootstrap Mojo *(esta entrega)*

- `pixi.toml`, `src/main.mojo`, `Application`, `Settings`, `Lifecycle`,
  `OrchestratorError` / `StatusCode`.
- `mojo run src/main.mojo` sobe o core e executa um self-check.
- `mojo build src/main.mojo -o build/agentd`.
- Python legado **não é removido**. `uv run ai-orchestrator-python`
  continua servindo HTTP/gRPC/IPC.

### Fase 2 — Domain

Structs: `Agent`, `Message`, `Execution`, `Conversation`, `Tool`,
`GenerationConfig`, estados e erros. Sem `dict[str, Any]` no core.

### Fase 3 — Graph / runtime

`Graph` / `Node` / `Edge` / `Router` / `Executor` / `Supervisor`.
O walk `retrieve → generate` e o `ExecuteAgent` passam a viver em Mojo.
Contratos observáveis:

- `execute_agent("default", "hello")` → texto `"[local] hello"`, id `exe-…`
- workflow default → `steps == ["retrieve", "generate"]`

### Fase 4 — Python compatibility

Isolar FastAPI, gRPC e futuros SDKs em `python/compatibility/` +
`adapters/python/`. Domain/graph **não** importam CPython.
`Application.serve()` (Mojo) passa a ligar transports via uma chamada
coarse-grained (`start_http`, `start_grpc`), não no hot loop.

HTTP/gRPC **não** viram microserviços. Continuam no mesmo processo,
CPython embutido, até existir motivo de isolamento.

### Fase 5 — RAG / compute

Já iniciado com hash embed, cosine e top-k (paridade com
`LocalLlm` / `MilvusVector`). Próximos:

- chunker nativo
- SIMD no embed/cosine se o índice crescer
- cliente ACE1 para data-engine / compute-engine
- rerank real (hoje zeros)

### Fase 6 — Cleanup

Remover use cases, domain, orchestration e adapters in-process
Python depois que `tests/mojo` + e2e via `agentd` cobrirem o mesmo
comportamento. `pyproject.toml` fica só com FastAPI/gRPC/SDKs.
O script `ai-orchestrator-python` some.

## 8. Fronteira Mojo ↔ Python

Permitido (coarse-grained):

```text
Mojo Application.serve()
  → uma vez: Python.start_http(settings)
  → uma vez: Python.start_grpc(settings)
  → por request HTTP: Python DTO → Mojo execute_agent → Python response
```

Proibido:

- LangGraph/Python decidindo o próximo node
- hot loop de similaridade em Python
- domain Mojo importando `openai` / `fastapi`

Socket unix: igual ao `vision-inference-engine` — framing em Mojo,
`socket` stdlib via `std.python` no adapter de I/O, não no domínio.

Worker separado (UDS/gRPC) **não** entra agora. Só se HTTP/gRPC
asyncio se tornar um subsistema que precise isolar crash ou escalar
sozinho.

## 9. Compatibilidade comportamental

Invariantes a preservar em cada port:

| Superfície | Input | Output / side effect |
| --- | --- | --- |
| agent local | `agent_id=default`, `prompt=hello` | `text == "[local] hello"`, `execution_id` prefixo `exe-` |
| agent inexistente | `agent_id` desconhecido | erro `not_found` |
| agent + retrieve | `retrieve=true`, índice default | `context` não vazio para query "ACE1" |
| workflow default | `prompt=*` | `steps == ["retrieve", "generate"]`, texto contém `[local]` |
| ACE1 health | type 1 | type 2, payload versão |
| ACE1 frame | header 20 bytes LE, magic `ACE1` | roundtrip idêntico |
| Local embed | texto | vetor L2, dim 32, estável |
| Vector search | query + top_k | ordem por score desc |
| HTTP `/agents/execute` | JSON | 200 + mesmo texto (enquanto HTTP for Python) |
| tool `echo` | `{text}` | eco; outra tool → `ok=false` |

Não mudar: prefixo env `AOR_*`, binds default, magic ACE1, tipos de
mensagem 210/211/220/221.

## 10. Decisões desta iteração

1. **Não** big-bang: Python em `src/ai_orchestrator/` fica no lugar.
2. Fundação Mojo em `src/{app,domain,graph,...}` + `src/main.mojo`.
3. Local LLM, índice vetorial in-memory, grafo, agente e ACE1
   framing vão para Mojo **agora** — não há SDK que os justifique
   em Python.
4. FastAPI/gRPC permanecem o servidor legado até a Fase 4.
5. Dois binários temporários: `./build/agentd` (Mojo) e
   `uv run ai-orchestrator-python` (Python). O primeiro é o futuro.

## 11. Critério de sucesso da migração

O repositório deve poder ser descrito como:

> Sistema agentic em Mojo que ocasionalmente usa bibliotecas Python.

Sinais:

- `main()` é Mojo
- graph/agent/state/RAG local não importam Python
- `pixi run test` cobre domínio e grafo
- `uv run pytest` ainda passa no legado até a Fase 6
- desligar `adapters/python` não quebra execute local
