# Terraform: primeiro laboratório sem cloud

Estado: IMPLEMENTED para `labs/local`; cloud está DOCUMENTED ONLY.
O recurso `terraform_data` grava um contrato no state: não cria cluster nem
valida IAM, networking ou infraestrutura AWS/Azure. Serve para observar o
ciclo plan/apply, diferenças entre input/output e mudanças rastreadas.

```sh
terraform -chdir=infrastructure/terraform/labs/local init
terraform -chdir=infrastructure/terraform/labs/local fmt -check
terraform -chdir=infrastructure/terraform/labs/local validate
terraform -chdir=infrastructure/terraform/labs/local plan -out=local.tfplan
terraform -chdir=infrastructure/terraform/labs/local show local.tfplan
# Após revisar o plano, aplicar no laboratório local:
terraform -chdir=infrastructure/terraform/labs/local apply local.tfplan
terraform -chdir=infrastructure/terraform/labs/local output
```

`init` prepara o diretório de trabalho; `validate` verifica consistência;
`plan` calcula mudanças, sem aplicá-las; `apply` altera o state. Uma falha de
lock exige investigar o processo dono do lock, não removê-lo às cegas.
Não versionar state ou planos: eles podem conter dados sensíveis.

Limpeza somente após confirmação humana explícita:
`terraform -chdir=infrastructure/terraform/labs/local destroy`.
Mesmo sem cloud, praticar inspeção do plano destrutivo e confirmação.

Antes da fase AWS/Azure: escolher região, limites de custo, identidade, rede,
versão suportada de Kubernetes e backend remoto com criptografia, controle
de acesso, versionamento e locking. S3/Azure Blob possuem mecanismos diferentes;
documentar o escolhido. Módulos terão fronteiras network, identity, cluster,
storage e GPU; ambientes terão roots/state independentes. Não copiar módulos
por ambiente nem compartilhar ownership com Crossplane.

Não fornecemos um `apply` de cloud que pareça completo sem essas decisões.
O gate obrigatório e seu formulário estão em `docs/finops/cloud-approval.md`.
