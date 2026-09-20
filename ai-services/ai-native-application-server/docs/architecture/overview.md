# Arquitetura-alvo

O AI Native Application Server é um produto com dois processos obrigatórios e
papéis diferentes. Rust é o Application Server completo e o único ingress.
Mojo é o runtime agentic interno, disponível para os casos de uso que precisem
de agentes.

```text
Cliente
  -> Rust transport
      -> autenticação, validação e use case
          -> fluxo tradicional -> ports/adapters/dados -> resposta
          -> fluxo agentic -> AgentRuntime port
              -> Mojo: agent -> graph/nodes/tools -> RAG/retrieval/inference
              -> resultado interno
          -> Rust monta a resposta pública
```

Não existe caminho Cliente -> Mojo. O transporte Rust/Mojo é um detalhe de
adapter e pode mudar entre REST, gRPC, socket ou IPC sem alterar o use case.

O baseline Mojo atual ainda contém HTTP público e responsabilidades de backend;
essas superfícies são transitórias e não representam a arquitetura-alvo.
