# Preparar GitOps

Estado: manifests criados, Argo CD não instalado nem sync executado.
`gitops/argocd/project.yaml` permite apenas o repositório real e namespace
`orzyon`, com tipos de recurso explícitos. A Application exige substituir
`SET_REVIEWED_COMMIT_SHA` por commit revisado e publicado; não usamos branch
inexistente como se deployment estivesse pronto.

Pré-requisitos: Argo CD instalado com versão revisada, acesso de leitura ao
repositório (credenciais fora do Git), namespace e Secret existentes, imagem
versionada disponível no registry/nodes. CI apenas testa/builda; não publica
imagem nem faz deploy automaticamente nesta entrega.

Após preparar o ambiente local e revisar o SHA:

```sh
kubectl --context kind-orzyon apply -f gitops/argocd/project.yaml
kubectl --context kind-orzyon apply -f gitops/argocd/application.yaml
```

Sync inicial é manual. Examine diff e health no Argo CD antes de sincronizar.
Para laboratório de drift, habilite `spec.syncPolicy.automated.selfHeal: true`
via alteração versionada, sem habilitar prune implicitamente. Git define duas
réplicas; em cluster descartável, alteração manual para cinco demonstra drift
e deve ser reconciliada. Registre eventos e tempo, não apenas estado final.

Rollback normal: reverter commit de configuração/modelo/imagem, revisar diff e
sincronizar. Remover Application não remove workloads automaticamente neste
manifest, que não contém finalizer de cascata. Qualquer exclusão/limpeza exige
confirmação e plano explícito para workloads, secrets e dados.
