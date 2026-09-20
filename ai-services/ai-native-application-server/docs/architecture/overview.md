# Arquitetura

O `agentd` é um serviço hexagonal integralmente Mojo. Um loop `poll(2)` atende
o listener HTTP/TCP e o listener ACE1/Unix no mesmo processo. Ambos despacham
para os mesmos use cases e domínio.

```text
main.mojo
  → bootstrap.Application.build()
    → transport.Service
      ├─ HTTP Router → Endpoint → Handler → Use Case
      └─ IPC ACE1 → Application.handle()
        → Agent / Workflow / RAG / Domain
```

Chamadas ao sistema operacional ficam isoladas em `src/infrastructure/`.
