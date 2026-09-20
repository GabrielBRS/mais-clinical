# Camadas Mojo

- `src/domain/`: tipos, regras e traits sem I/O.
- `src/application/`: use cases, agentes, grafo, RAG e lifecycle.
- `src/bootstrap/`: composition root e wiring.
- `src/transport/`: HTTP (router, endpoints com handlers) e IPC ACE1.
- `src/infrastructure/`: sockets POSIX, ambiente, compute e adapters locais.

Em compile time, `mojo build` transforma `src/main.mojo` em `build/agentd`.
Em runtime, somente esse binário atende os transports e executa a aplicação.
