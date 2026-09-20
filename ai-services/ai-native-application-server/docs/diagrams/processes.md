# Processos

```text
Internet / clientes
  |
  v
ai-native-runtime (Rust, público :8080)
  ├─ use cases tradicionais -> bancos / filas / serviços
  └─ use cases agentic
       |
       v rede privada
     mojo-agent-runtime (:8090 interno, nunca publicado)
       └─ agents / graph / nodes / tools / RAG / inference / kernels
```

Todo projeto distribui os dois processos. A ausência de uma chamada agentic em
determinado fluxo não altera a rota tradicional nem cria um hop desnecessário.
