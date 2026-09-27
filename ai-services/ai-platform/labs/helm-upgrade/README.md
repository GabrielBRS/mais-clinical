# Lab 005 — Upgrade e reversão

Objetivo: compreender release, revision e diferença entre rollout e estado Git.
Arquitetura: release local `orzyon`, sem Argo CD ativo. Pré-requisitos: fase de
deploy local concluída e capacidade para segunda réplica.

```sh
helm template orzyon helm/platform -n orzyon --set replicaCount=2
helm upgrade orzyon helm/platform --kube-context kind-orzyon -n orzyon --set replicaCount=2 --wait --atomic
helm history orzyon --kube-context kind-orzyon -n orzyon
kubectl --context kind-orzyon -n orzyon get pods
```

Esperado: duas réplicas Ready e nova revisão. Falha: requests maiores que a
capacidade deixam Pod Pending; diagnostique eventos em vez de repetir upgrades.
Reversão após confirmação: `helm rollback orzyon REVISAO_ANTERIOR --kube-context
kind-orzyon -n orzyon --wait`. Cleanup da release somente se não houver outro lab
dependente. Produção/GitOps: reverta values no Git; Argo CD desfaz alterações locais.
Perguntas: rollback de imagem também reverte dados? Por que PDB não cria capacidade?
