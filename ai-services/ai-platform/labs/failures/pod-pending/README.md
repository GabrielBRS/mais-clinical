# Lab 003 — Pod que não progride

Objetivo: produzir hipóteses de scheduling a partir de evidência. Arquitetura:
Pod descartável no namespace `orzyon` do kind. Pré-requisitos: cluster do runbook,
namespace existente; não executar em cluster cloud com autoscaler pago.

```sh
kubectl --context kind-orzyon apply -f labs/failures/pod-pending/pod.yaml
kubectl --context kind-orzyon -n orzyon get pod scheduling-lab
kubectl --context kind-orzyon -n orzyon describe pod scheduling-lab
kubectl --context kind-orzyon -n orzyon get events --sort-by=.metadata.creationTimestamp
```

Esperado: Pod permanece Pending. Antes de ler abaixo, registre três hipóteses,
uma evidência que sustenta cada uma e qual observação a refutaria. Diferencie
erro de scheduling de ImagePullBackOff. Não altere labels de nodes sem entender
os efeitos em outros workloads.

Troubleshooting: se o Pod agendar, inspecione labels do node e confirme que o
arquivo aplicado é o deste laboratório. Cleanup, após confirmação humana:
`kubectl --context kind-orzyon -n orzyon delete pod scheduling-lab`.

Perguntas: toleration é seleção? Requests são uso atual? Preemption resolve
restrição impossível? Produção: corrigir configuração no Git e avaliar capacidade
antes de adicionar nodes; label GPU não cria GPU física.

<details><summary>Solução e evidências esperadas</summary>

WHAT: sem node compatível. WHY: nodeSelector exige label não presente.
HOW: evento FailedScheduling e mensagem de afinidade/selector.
Metric: estado Pending seria observável com kube-state-metrics, não instalado
na base atual. Log: container não iniciou; ausência de log não é falha de logging.
Trace: não há requisição da aplicação, portanto não há span correspondente.
Mitigar: remover a restrição no arquivo de laboratório e reaplicar, se autorizado.
Prevenir: revisar selectors, validar capacidade e testar manifests em cluster.

</details>
