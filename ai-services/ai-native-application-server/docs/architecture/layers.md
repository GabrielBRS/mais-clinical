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

## Mojo Agent Runtime

- agentes, supervisor e registry;
- graph, nodes, routing, workflows e state agentic;
- tools e execution harness;
- RAG, retrieval, embeddings e reranking agentic;
- tokenização, inferência e kernels;
- transport interno e health próprio.

Mojo não contém API pública, autenticação de cliente, CRUD tradicional ou
ownership da resposta HTTP externa.
