# Labs 009–010 — MCP e permissão

Objetivo: negociar capabilities, listar e chamar tools, observar negação.
Arquitetura: SDK oficial → HTTP loopback → MCP → corpus real. Pré-requisitos:
`uv sync --frozen`, token válido e API iniciada. Sem GPU ou cloud.

```sh
uv run pytest tests/test_live_mcp.py -q
uv run python scripts/mcp_smoke.py
```

O primeiro comando inicia servidor temporário e testa TCP real; o segundo usa
servidor do operador e `ORZYON_API_TOKEN` no ambiente. Esperado: três conjuntos
de tools e documento recuperado por busca. Platform MCP fora do cluster retorna
erro de credencial ausente, não status fictício de cluster saudável.

Failure: execute smoke com token errado e chame `retrieve_document` com `../.env`
por um cliente MCP. Observe negação/erro; consulte `/metrics` para tool errors.
Não tentar isso contra sistemas de terceiros.

Troubleshooting: lifecycle, URL com barra final, Host/Origin e header Bearer.
Cleanup: Ctrl+C no servidor manual; processo do teste é encerrado pelo fixture.
Perguntas: por que `tools/list` não concede permissão? O que impede SSRF aqui?
Produção: OAuth/scopes, callers, TLS, rate limit e isolamento físico dos servidores.
