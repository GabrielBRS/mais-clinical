# ADR-0004 — Secrets e telemetria inicial

Status: adotado apenas para laboratório.

## Context

Temos que diagnosticar falhas sem gravar credenciais ou conteúdo de usuário.

## Decision

Secrets locais em `.env` ignorado; Kubernetes referencia Secret existente.
Prometheus usa labels de cardinalidade limitada; logs de tools contêm nome,
resultado e duração, sem argumentos. OpenTelemetry exporta spans opcionais.
Coletores locais são efêmeros. pip-audit é o scanner inicial de dependências.

## Alternatives considered

SOPS fornece secrets cifrados em Git, mas exige gestão de chaves; External Secrets
Operator integra secret managers de cloud e será avaliado na fase correspondente.
Vault é poderoso mas adiciona serviço crítico e rotina de unseal/backup. Telemetria
proprietária pode acelerar diagnóstico, com custo e acoplamento adicionais.

## Consequences

Nenhum Secret real em values. `.env` não é carregado automaticamente pelo cliente
MCP de smoke, que usa variável de ambiente explícita. Métricas/health são públicos
na rede local para scrape; não expor o serviço diretamente à Internet.

## Risks

Secret Kubernetes não é criptografia por si só. Dev precisa de token compartilhado;
produção precisa de identidade, scopes, auditoria de caller, retenção e redaction.

## Revisit conditions

Primeiro ambiente compartilhado ou cloud. Selecionar secret manager, workload
identity, TLS e estratégia de rotação antes desse ambiente.
