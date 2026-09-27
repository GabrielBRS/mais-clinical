# Objetivo

Construir e diagnosticar o caminho processo → container → Pod → Service.

# Fundamentos

Imagem é um artefato em camadas; container é processo isolado por primitivas do
kernel. Namespace Linux limita a visão; cgroup contabiliza/restringe recursos.
Container não é VM. Deployment mantém réplicas por controller; Service seleciona
endpoints por labels. Requests afetam scheduling; limits afetam execução.

# Como funciona internamente

`kubectl apply` envia configuração ao API Server, que valida/admite e persiste
estado via etcd. Controllers observam mudanças pela API e reconciliam objetos.
Scheduler escolhe node para Pod ainda não vinculado; kubelet pede ao runtime
para iniciar containers. Controllers/scheduler não acessam etcd diretamente.
CNI configura rede; CSI integra armazenamento quando utilizado.

# Relação com nossa arquitetura

`Dockerfile` define processo; `helm/platform` define Deployment, Service,
ConfigMap, ServiceAccount e Role. `kubernetes/kind.yaml` define nodes locais.

# Laboratório

Execute labs 001, 002 e 005 no [índice](../../labs/README.md). Explique cada campo
do chart antes de alterar réplicas. Use `helm template` para ver YAML concreto.

# Failure Lab

Execute `labs/failures/pod-pending`. Registre hipóteses antes de abrir a solução.

# Troubleshooting

Separe API rejeitada, Pod não agendado, imagem não baixada, processo falhando e
readiness falhando. Siga [o runbook](../troubleshooting/kubernetes.md).

# Production considerations

Nodes locais não validam zonas, identidade cloud, LB, storage persistente ou GPU.
Não use probes externas para liveness. Não use aumento de limits como substituto
de diagnóstico. Planeje políticas, múltiplas zonas, backups e rollback.

# Perguntas de domínio

Qual controller cria o Pod? Por que Ready e Running diferem? O Service tem
endpoints quando readiness falha? Por que toleration não garante scheduling?
Quem aplica limite de memória? Como uma tag reutilizada prejudica rollback?

# Checklist

- [ ] Construí e inspecionei a imagem e expliquei USER/CMD/layers.
- [ ] Executei deployment e identifiquei readiness e recursos reais.
- [ ] Diagnostiquei Pending com evidência e corrigi no arquivo versionado.
- [ ] Demonstrei rollback e registrei limitações de produção.

# Referências

Ver biblioteca oficial: Linux, OCI, Docker, Kubernetes, scheduler e Helm.
