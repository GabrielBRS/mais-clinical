# Executar, observar e reverter localmente

## Windows, WSL e ferramentas

Estado observado: Windows/PowerShell, WSL padrão 2 sem distribuição instalada.
Docker/kind/kubectl não foram encontrados no PATH. Python foi provisionado pelo
uv, sem depender do runtime de outro aplicativo. Helm 3.17.3 e Terraform 1.11.4
foram baixados em `.tools` e tiveram SHA256 comparado com checksum do fornecedor.
Nada disso comprova execução de Linux, container ou Kubernetes.

Windows: `wsl --status` mostra configuração; `wsl --list --verbose` mostra
distribuições. Prepare Ubuntu/WSL2 e Docker Desktop com integração WSL conforme
documentação oficial, ou use Docker Engine em Linux. Instalação de componentes
do Windows pode exigir administrador/reinício e não foi automatizada.

No terminal Linux escolhido, confira separadamente:

```sh
docker version
docker info
kind version                 # referência: v0.33.0
kubectl version --client     # compatível com cluster 1.35
helm version                # chart validado com 3.17.3
terraform version           # laboratório validado com 1.11.4
uv --version                # lock produzido com 0.8.22
```

`docker version` precisa mostrar Client **e Server**. Socket negado, engine
parado ou distribuição sem integração não são ausência de Python. Evite alternar
entre Docker Windows e Linux sem saber qual daemon armazena as imagens.

## Compose

Na pasta da plataforma, copie `.env.example` e preencha API token e senha Grafana.
`docker compose config --quiet` valida interpolação sem imprimir secrets.

```sh
docker compose config --quiet
docker compose up --build -d platform prometheus grafana otel
docker compose ps
docker compose logs --tail=100 platform otel
```

UI: porta 8000; Grafana: 3000 (`admin` e senha escolhida); Prometheus: 9090.
Em Prometheus, consulte `up{job="orzyon"}`. No dashboard Orzyon, gere buscas e
chamadas MCP antes de avaliar séries; métricas de tools surgem após a primeira
chamada. Collector registra spans no log, sem backend de pesquisa/retention.
Alertas são avaliados no Prometheus; não há Alertmanager ou notificações externas.

API em Docker não possui credencial Kubernetes: Platform MCP retorna erro claro.
Para usá-lo de verdade, faça o deploy Helm abaixo.

O perfil `inference` não é iniciado por padrão. Antes de habilitá-lo, verificar
GPU/driver/NVIDIA Container Toolkit, compatibilidade da imagem/modelo, licença,
espaço de cache e chaves distintas `ORZYON_GATEWAY_TOKEN` e `VLLM_API_KEY`.
O exemplo de modelo não é recomendação de qualidade ou capacidade.

```sh
docker compose --profile inference up -d
docker compose logs --tail=100 vllm litellm
```

Imagem/modelo podem levar minutos para baixar e carregar. Só usar a UI para
geração após confirmar readiness do runtime. Não habilitar provider externo
sem orçamento e aprovação para suas cobranças. Tags estão fixadas, mas a
compatibilidade GPU e o scanning dessas imagens ainda não foram executados.

## kind e Helm

```sh
kind create cluster --name orzyon --config kubernetes/kind.yaml
kubectl --context kind-orzyon get nodes
kubectl --context kind-orzyon apply -f kubernetes/namespace.yaml
```

`kind create` cria nodes como containers no daemon local. O config fixa digest
de Kubernetes 1.35.8. Esperado: dois nodes Ready. Pending/NotReady exige eventos,
logs do kubelet/container runtime e verificação de CPU/RAM do Docker.

Criar Secret local sem colocar o valor na linha de comando (shell POSIX):

```sh
mkdir -p secrets
umask 077
uv run python -c 'import secrets; from pathlib import Path; Path("secrets/api-token").write_text(secrets.token_urlsafe(32))'
kubectl --context kind-orzyon -n orzyon create secret generic orzyon-api --from-file=api-token=secrets/api-token
```

`secrets/` é ignorado. No PowerShell, use a mesma chamada Python após
`New-Item -ItemType Directory -Force secrets`; proteja o arquivo via ACL local.
O comando `create` falha se o Secret já existir: não rotacionar implicitamente.
Rotação requer confirmação humana conforme especificação.

```sh
docker build -t orzyon/platform:0.1.0 .
kind load docker-image orzyon/platform:0.1.0 --name orzyon
helm lint helm/platform
helm template orzyon helm/platform -n orzyon
helm upgrade --install orzyon helm/platform --kube-context kind-orzyon -n orzyon --wait --atomic --timeout 3m
kubectl --context kind-orzyon -n orzyon rollout status deployment/orzyon-platform
kubectl --context kind-orzyon -n orzyon port-forward svc/orzyon-platform 8000:8000
```

`helm template` apenas renderiza; não testa admission nem execução. `--wait`
aguarda readiness e `--atomic` reverte upgrade falho. Use uma tag nova para
cada alteração da imagem e passe `--set image.tag=VERSAO` ao upgrade.
Readiness indica que API/corpus/MCP inicializaram; dependência LLM indisponível
não derruba busca. Liveness não chama serviços externos para evitar restart storm.

No outro terminal, exporte o token do arquivo e execute `scripts/mcp_smoke.py`.
Para provar RBAC, testar explicitamente:

```sh
kubectl --context kind-orzyon auth can-i list deployments -n orzyon --as=system:serviceaccount:orzyon:orzyon-platform
kubectl --context kind-orzyon auth can-i delete deployments -n orzyon --as=system:serviceaccount:orzyon:orzyon-platform
kubectl --context kind-orzyon auth can-i get secrets -n orzyon --as=system:serviceaccount:orzyon:orzyon-platform
```

Esperado: yes, no, no. São verificações de autorização, não mutações.
Observabilidade do Compose não é automaticamente alcançável pelo cluster:
instale Prometheus/collector no cluster ou configure endereços realmente roteáveis
via values. Não confundir dashboard Compose com monitoramento Kubernetes pronto.

## Reversão e limpeza — após confirmação humana

```sh
helm history orzyon --kube-context kind-orzyon -n orzyon
helm rollback orzyon REVISAO --kube-context kind-orzyon -n orzyon --wait
helm uninstall orzyon --kube-context kind-orzyon -n orzyon
kind delete cluster --name orzyon
docker compose down
```

Rollback exige revisão existente. Uninstall preserva o namespace/Secret; exclusão
do cluster perde seus recursos. `compose down` preserva volumes nomeados, como
cache de modelos; `down -v` apaga volumes e exige confirmação específica.
Não executar `docker system prune` como cleanup deste projeto.
