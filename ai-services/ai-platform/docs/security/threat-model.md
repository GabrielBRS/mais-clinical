# Threat model inicial

Escopo: laboratório single-tenant, corpus público, tools somente leitura.
Ativos: token, documentos, identidade Kubernetes, metadados de deployments,
telemetria, acesso ao gateway e orçamento. Não usar dados clínicos reais.

| Ameaça/fronteira | Controle implementado | Lacuna e evolução |
| --- | --- | --- |
| Acesso sem identidade | Bearer obrigatório; token mínimo; comparação constante | Token compartilhado não identifica usuário; OAuth/OIDC + scopes antes de rede compartilhada |
| Tool abuse/escalada | Allowlist de tools; nenhum shell/mutação; Role somente list deployments | Processo compartilhado; separar ServiceAccounts e autorizar cada tool |
| SSRF | Usuário não fornece URLs; endpoints definidos pelo operador; redirects HTTP não seguidos nos backends | Restringir egress por CNI/proxy e validar configuração na revisão |
| Exfiltração por path | ID de documento, root fixo, symlinks externos rejeitados | Corpus deve ser confiável e read-only; snapshot não possui ACL de tenant |
| Prompt injection/RAG poisoning | Tools imutáveis, instrução para tratar documentos como dados | Prompt não é isolamento; revisão de ingestão e autorização por documento pendentes |
| Confused deputy | Backend namespace fixo; token da plataforma não é encaminhado ao gateway | Sem propagação de identidade de usuário; não adequado a connectors pessoais |
| Custo/loops | Um retrieval e uma geração, timeout total, max_tokens | Sem quota financeira/rate limiting distribuído; não expor a terceiros |
| Telemetria sensível | Logs sem argumentos, labels fixas, sem captura de prompt | Auditar bibliotecas, exceções e destino OTLP antes de dados reais |
| Supply chain | Lockfile, auditoria Python, container não-root | Scanning de imagens, SBOM, assinatura/provenance e digests pendentes |
| DoS | Corpus/resposta Prometheus limitados, timeout, limites Kubernetes | Body limits no proxy, concurrency/load shedding e rate limit pendentes |
| Rede lateral | Service ClusterIP e política de ingress opcional | kindnet não impõe policy; egress/TLS não implementados |

O token autoriza todas as tools de leitura deste laboratório. Não alegamos
autorização por usuário, tool ou tenant. `/health/*`, `/metrics` e a página inicial
são públicos para uso local; proteger rede e scraping em ambiente compartilhado.

Rotação de credenciais, deleções e mudanças de produção exigem confirmação humana.
Não capturar conteúdo sensível em fixtures. Testes de ataque ficam no ambiente
descartável próprio, com escopo limitado e cleanup aprovado.
