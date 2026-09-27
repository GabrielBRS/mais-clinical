# Objetivo

Entender lifecycle MCP, contrato de tool e evidência de falha sem dados sensíveis.

# Fundamentos

Client negocia capabilities ao inicializar, lista ferramentas e chama um contrato
com argumentos estruturados. Erro de tool pode vir em resultado MCP `isError`,
mesmo com HTTP 200. Métricas HTTP sozinhas não medem sucesso de ferramenta.

# Como funciona internamente

SDK oficial trata JSON-RPC e Streamable HTTP; a aplicação impõe autenticação
antes do protocolo. Middleware extrai trace context; spans de tool medem duração.
Prometheus coleta contadores e histogramas; Grafana consulta PromQL. `rate`
estima taxa em janela e precisa de amostras suficientes.

# Relação com nossa arquitetura

Três servidores lógicos em `mcp_servers.py`; os adaptadores em `backends.py`
fazem leitura real. O cliente em `agent.py` usa MCP para retrieval antes de LLM.
O workflow determinístico não permite ao modelo escolher qualquer operação.

# Laboratório

Execute teste TCP em `tests/test_live_mcp.py`, depois cliente `scripts/mcp_smoke.py`
contra serviço iniciado por você. Rode Compose e observe o dashboard de tools.

# Failure Lab

Chame MCP sem Authorization e com `delete_namespace`. Compare HTTP 401 com
resultado de tool inválida. Pare uma dependência apenas no laboratório, com
aprovação operacional, e observe erros e recuperação.

# Troubleshooting

401: identidade; 421: Host/Origin rejeitado; 404: path/mount; 503 na API de agente:
dependência/timeout; `isError`: tool falhou. Não desative DNS rebinding protection
para contornar configuração de hostname.

# Production considerations

Scopes/caller, user-scoped connectors, TLS, egress control, rate limits e separação
de processos ainda são necessários. Não registrar prompt/resposta por padrão.
Integração REST direta pode ser suficiente quando descoberta MCP não é necessária.

# Perguntas de domínio

Por que MCP não substitui API? O que acontece quando um cliente perde conexão?
Como evitar confused deputy? Por que sucesso HTTP não prova sucesso da tool?
Quando retry é seguro? Que cardinalidade cresce ao usar user_id como label?

# Checklist

- [ ] Fiz initialize/list/call com SDK oficial.
- [ ] Expliquei diferença entre erro HTTP e erro de tool.
- [ ] Observei métrica real e localizei o audit event correspondente.
- [ ] Identifiquei limites do token compartilhado e do processo único.

# Referências

Biblioteca oficial: MCP specification/SDK, OpenTelemetry, Prometheus e Grafana.
