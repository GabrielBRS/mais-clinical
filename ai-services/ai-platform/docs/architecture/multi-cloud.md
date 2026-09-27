# AWS/Azure e ownership — plano, não deployment validado

| Área | AWS / EKS a estudar | Azure / AKS a estudar |
| --- | --- | --- |
| Rede | VPC, subnets, CNI, rotas e endpoints | VNet, subnets, CNI e rotas |
| Identidade | IAM, identidades de Pod e acesso ao cluster | Entra, managed/workload identities e RBAC |
| Storage | EBS/EFS e CSI conforme workload | Disks/Files e CSI conforme workload |
| Registry | ECR e permissões de pull | ACR e identidade de pull |
| Capacidade | Managed node groups e Karpenter | Node pools e mecanismos suportados pelo AKS |
| GPU/Spot | Família, quota, AMI/driver e interrupção EC2 | SKU, quota, imagem/driver e eviction Spot |
| Secrets | Secret manager + workload identity | Key Vault + workload identity |
| Ingress/LB | Controller e integração com load balancers AWS | Integração suportada no ambiente AKS |
| Custos | Control plane, compute, NAT, volumes, logs e rede | Cluster tier, compute, rede, volumes e logs |

A tabela define dimensões de comparação, não equivalência garantida. Cada
escolha exige documentação da versão/região, ADR e evidência da execução.
Sem conta/região/orçamento aprovados, não há plano concreto de cloud revisável.

Terraform: redes, identidades e cluster. Argo CD: configuração e workloads.
Crossplane futuro: recursos delegados a uma API interna com ownership explícito.
Nunca manter o mesmo recurso em state Terraform e em reconciliação Crossplane.
Ambientes dev/staging/prod terão state/identidades separados; local não representa
isolamento multi-tenant ou paridade de serviços cloud.
