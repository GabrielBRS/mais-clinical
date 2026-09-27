# Contribuir

Trabalhe em `ai-services/ai-platform` a partir do monorepo existente. Não execute
`git init` aqui. Branches novas usam `codex/` por convenção, salvo decisão do time.
Não foi feito commit ou push automático desta entrega.

1. Leia README, ADRs e `docs/validation.md`.
2. Instale Python 3.12 com uv e execute `uv sync --frozen`.
3. Copie `.env.example`, gere token local e execute os testes.
4. Faça uma entrega pequena com falha exercitada, diagnóstico e reversão.
5. Atualize `uv.lock` com `uv lock` somente quando mudar dependências.
6. Execute Ruff, mypy, pytest, pip-audit e validações Helm/Terraform aplicáveis.
7. Abra PR descrevendo problema, comportamento, evidências e limites reais.

Workflows ficam em `mais-clinical/.github/workflows/ai-platform-ci.yml`.
Não alterar outros serviços sem necessidade. Não adicionar ferramentas ou bancos
sem problema concreto e ADR. Não registrar dados clínicos no corpus, testes,
logs, prompts ou benchmarks. Dados sintéticos precisam ser identificados.

Use tags rastreáveis e, em produção, digest de imagem e revisão de modelo.
Não sobrescreva uma tag já publicada. Em GitOps, rollback é uma reversão no Git;
`helm rollback` é reservado à fase local sem reconciliação ativa.
