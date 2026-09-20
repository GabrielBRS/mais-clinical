# ADR 0001 — Hexagonal

Ports no interior, adapters e transports na borda. Troca de LLM ou
vector store não mexe em use case.

HTTP driving adapters são endpoints. Cada endpoint possui um handler
que traduz o pedido para um use case.
