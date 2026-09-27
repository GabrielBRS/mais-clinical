# Diagnóstico por evidência

Sequência: sintoma → observação → hipóteses → evidência → causa → mitigação →
correção permanente → prevenção. Use sempre `--context kind-orzyon -n orzyon`
no laboratório para não operar outro cluster por engano.

| Sintoma | Comando e evidência | Próxima hipótese |
| --- | --- | --- |
| Pending | `kubectl describe pod NOME`; Events | selector/taint, CPU/RAM/GPU insuficiente, PVC sem binding |
| CrashLoopBackOff | `kubectl logs NOME --previous`; termination reason | configuração inválida, processo encerrou, liveness incorreta |
| ImagePullBackOff | `kubectl describe pod NOME` | tag inexistente, registry sem autenticação, DNS/rede |
| OOMKilled | estado anterior + limits; métricas quando disponíveis | pico de memória além do limite; medir antes de aumentar |
| Readiness falha | condições do Pod e probe path/porta | inicialização incompleta ou endpoint errado; não implica restart |
| DNS | resolver no Pod diagnóstico, Service e EndpointSlices | CoreDNS, nome/namespace incorreto, NetworkPolicy |
| Rede | Services/EndpointSlices, porta do processo, políticas | selector sem endpoints, port mapping ou CNI |
| GPU insuficiente | allocatable dos nodes e eventos | plugin ausente, recurso `nvidia.com/gpu` indisponível, restrições incompatíveis |

Comandos fundamentais:

```sh
kubectl --context kind-orzyon -n orzyon get pods -o wide
kubectl --context kind-orzyon get nodes -o wide
kubectl --context kind-orzyon -n orzyon get events --sort-by=.metadata.creationTimestamp
kubectl --context kind-orzyon -n orzyon describe pod NOME
kubectl --context kind-orzyon -n orzyon logs NOME --previous
kubectl --context kind-orzyon -n orzyon get deployment
kubectl --context kind-orzyon -n orzyon get endpointslices
kubectl --context kind-orzyon -n orzyon top pods
```

`describe` reúne estado e eventos, `logs --previous` consulta a instância anterior
do container, `top` depende de metrics-server (não instalado por este projeto).
Ausência de metrics-server não prova ausência de carga. `get events` tem retenção
limitada; capture evidências cedo, sem secrets.

`kubectl rollout undo deployment/NOME` demonstra histórico local, mas não é o
procedimento normal sob Argo CD: nesse caso reverta o commit e observe sync.
Mudanças de rollback também seguem a política de confirmação da especificação.
