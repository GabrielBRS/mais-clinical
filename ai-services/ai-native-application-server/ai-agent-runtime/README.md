# AI Agent Runtime

Runtime Mojo privado do AI Native Application Server. `agentd`:

- atende REST/HTTP somente na rede interna;
- embute CPython sem subprocesso;
- carrega o contrato em `../ai-agent-contract`;
- mantém um `PythonContractRegistry` com os módulos carregados;
- executa o `AppContainer` e devolve o resultado ao Rust.

`src/contracts/ai_orchestrator/` espelha o pacote Python 1:1. Esses loaders são
gerados por `scripts/generate_agent_contract_loaders.py`; não devem ganhar uma
segunda implementação da lógica agentic.

```bash
pixi install --locked
pixi run test
pixi run build
```

A build grava `build/agentd` dentro deste diretório. `deploy.py`, na raiz do
repositório, move esse binário para `builds/ai-agent-runtime/agentd`.
