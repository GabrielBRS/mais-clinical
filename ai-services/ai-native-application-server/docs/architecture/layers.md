# Camadas e ownership

## Rust Application Server

- `domain/`: domínio de negócio tradicional;
- `application/`: casos de uso, inclusive os que optam por invocar agentes;
- `ports/`: contratos de bancos, mensageria, storage, integrações e
  `AgentRuntime`;
- `adapters/`: implementações de dados e o cliente interno do Mojo;
- `transport/`: HTTP/gRPC público, autenticação, autorização e validação;
- `bootstrap/`: configuração, lifecycle e composition root;
- `observability/`: logs, métricas, tracing e correlation ID.

## Python AI Agent Contract

- `ai-agent-contract/src/ai_orchestrator/domain/`: agentes, mensagens, execução e workflows;
- `ai-agent-contract/src/ai_orchestrator/usecase/`: casos de uso agentic;
- `ai-agent-contract/src/ai_orchestrator/orchestration/`: executores, routing e estado;
- `ai-agent-contract/src/ai_orchestrator/adapter/`: LLM, vector, memory, storage, RPC e IPC;
- `ai-agent-contract/src/ai_orchestrator/bootstrap/`: `AppContainer` e composition root.

## Mojo AI Agent Runtime

- `ai-agent-runtime/src/contracts/`: loaders 1:1 e registro dos módulos Python;
- `ai-agent-runtime/src/host/interop/`: CPython embutido e `Python.import_module()`;
- `ai-agent-runtime/src/host/transport/`: HTTP/IPC estritamente privados;
- `ai-agent-runtime/src/host/config.mojo`: configuração do processo interno;
- `ai-agent-runtime/src/main.mojo`: entrypoint `agentd`.

Mojo não contém agentes, grafo, RAG, API pública, CRUD tradicional ou ownership
da resposta HTTP externa.
