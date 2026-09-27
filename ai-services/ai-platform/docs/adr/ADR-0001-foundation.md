# ADR-0001 — Fundação local no monorepo

Status: adotado para a entrega 0.1.0.

## Context

O diretório pertence a `mais-clinical`. O host é Windows, sem distribuição WSL
instalada. Precisamos testar lógica sem vincular a execução a Docker ou GPU.

## Decision

Manter o monorepo, Python 3.12, uv com lockfile e pacote em `src/orzyon`.
FastAPI serve API e UI mínima. Windows nativo suporta testes; WSL2/Linux é o
alvo preferido dos laboratórios de containers, kind e Make.

## Alternatives considered

Poetry também oferece lock/ambientes; uv concentra aquisição de Python e sync
com menor número de ferramentas. pip com constraints funciona, mas exige cuidar
separadamente de resolução transitiva e ambiente. Python 3.14 é deliberadamente
adiado até confirmar suporte das bibliotecas de IA. Repositório separado facilita
permissões, mas prejudica a rastreabilidade inicial entre os serviços existentes.

## Consequences

Instalação usa `uv sync --frozen`; CI trabalha a partir da raiz Git real. Mudanças
de dependência atualizam pyproject e lock juntas. `.tools` não é distribuído.

## Risks

Lockfile não garante ausência de vulnerabilidades ou builds bit a bit idênticos.
Imagens base precisam de digest e scanning antes da promoção.

## Revisit conditions

Suporte comprovado a outra versão Python, gargalo medido, necessidade de publicar
serviços independentemente ou exigência de isolamento entre equipes.
