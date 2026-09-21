# AI Agent Contract

Fonte de verdade Python das definições agentic do AI Native Application
Server: domínio, agentes, grafos, casos de uso, orchestration e adapters.

Este diretório não é um serviço público. O processo
`ai-agent-runtime/` adiciona `ai-agent-contract/src` ao CPython embutido,
carrega `ai_orchestrator` e conserva os objetos durante a vida de `agentd`.

Depois de criar, mover ou remover um módulo Python, regenere os loaders Mojo:

```bash
just generate-contract-loaders
```
