# Fronteira de runtime

O processo `agentd` não embute runtime auxiliar.

- ambiente: `std.os.getenv`;
- TCP e sockets Unix: chamadas POSIX via `std.ffi.external_call`;
- grafo: `application.graph.GraphRuntime`;
- tokenização e embeddings locais: módulos Mojo em `infrastructure/local`;
- framing: codec ACE1 em `infrastructure/ipc/protocol.mojo`.

Integrações externas entram por contratos de rede, mantendo a propriedade do
processo e toda a lógica agentic no binário Mojo.
