# Lab 004 — Processo ativo, serviço indisponível

Objetivo: distinguir execução e readiness. Arquitetura: release Helm separada
`probe-lab`, usando Secret existente e a mesma imagem local. Pré-requisitos:
kind com imagem carregada e namespace/Secret criados.

```sh
helm upgrade --install probe-lab helm/platform --kube-context kind-orzyon -n orzyon -f labs/failures/bad-readiness/values.yaml
kubectl --context kind-orzyon -n orzyon get pods -l app.kubernetes.io/instance=probe-lab
kubectl --context kind-orzyon -n orzyon describe deployment probe-lab-platform
kubectl --context kind-orzyon -n orzyon get endpointslices -l kubernetes.io/service-name=probe-lab-platform -o yaml
```

Não usamos `--atomic` neste exercício para poder investigar o estado falho.
Esperado: rollout não fica pronto. Hipóteses: processo caiu? Porta errada?
Probe chama endpoint incorreto? Encontre o Pod com `get`, use `describe pod NOME`
e correlacione eventos e restarts antes da solução.

Cleanup após confirmação: `helm uninstall probe-lab --kube-context kind-orzyon
-n orzyon`. Produção: não testar isso na release compartilhada; probe deve
refletir capacidade de servir sem causar cascata por dependência externa.
Perguntas: readiness reinicia container? EndpointSlice Ready=false permite tráfego?

<details><summary>Solução e diagnóstico</summary>

WHAT: Pod Running mas não Ready. WHY: values define `/missing-readiness`.
HOW: readiness HTTP falha; liveness continua no endpoint correto.
Metric: HTTP status registra falhas; métricas de estado do Pod exigem exporter
adicional. Log/evento: kubelet relata probe; acesso HTTP não é logado pela API.
Trace: com OTLP ativo pode haver span da requisição, sem captura de corpo.
Mitigar: upgrade sem values de falha, com `--reset-values --wait` após revisão.
Prevenir: testar probe path no CI e rollout com timeout/rollback.

</details>
