# ADR-0002 — Compose, kind e Helm

Status: adotado para laboratório, sem validação de execução no cluster ainda.

## Context

Aprender os objetos Kubernetes sem esconder comandos, mantendo um caminho rápido
para integrar métricas e serviços em máquinas com Docker.

## Decision

Compose integra serviços locais. kind fornece Kubernetes descartável; Helm
empacota o workload próprio. Probes, recursos, RBAC e restrições de container
são explícitos. Secret é criado pelo operador e nunca renderizado no chart.

## Alternatives considered

k3d é leve, mas usa a distribuição k3s; kind aproxima os laboratórios de
Kubernetes upstream. Minikube oferece addons úteis, com mais escolhas de driver.
Kustomize simplifica overlays, mas Helm permite estudar pacote e rollback.
Nenhuma dessas ferramentas substitui testes em EKS/AKS.

## Consequences

Inicialmente uma réplica e acesso por port-forward. PDB só com duas ou mais
réplicas. NetworkPolicy opcional é somente ingress e precisa de CNI com suporte;
kindnet não fornece a garantia pretendida. Não alegamos zero trust implementado.

## Risks

Compartilhar processos amplia impacto de falha. Imagens locais com mesma tag
podem ficar antigas nos nodes: incrementar a versão antes de rebuild/deploy.

## Revisit conditions

Múltiplos usuários, ingress externo, políticas de egress ou necessidade de
validar autoscaling e GPUs. Considerar Cilium/Calico em laboratório próprio.
