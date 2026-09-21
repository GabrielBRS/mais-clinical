# ADR 0001 — Hexagonal

Ports no interior, adapters e transports na borda. Troca de LLM ou
vector store não mexe em use case.

A arquitetura hexagonal agentic é definida no contrato Python
`ai-agent-contract/src/ai_orchestrator`. O runtime Mojo não replica a lógica
dessas camadas: seus módulos homólogos carregam e conservam os objetos Python e
o processo faz hosting/interop entre a porta interna Rust e o composition root.

HTTP driving adapters são endpoints. Cada endpoint possui um handler
que traduz o pedido para um use case.
