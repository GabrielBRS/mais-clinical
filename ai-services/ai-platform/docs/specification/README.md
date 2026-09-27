# Especificação recebida

Os textos abaixo foram fornecidos pelo responsável pela Orzyon AI Platform e
preservados integralmente, sem completar trechos ausentes por inferência.

| Documento | Cobertura recebida | Limite do arquivo |
| --- | --- | --- |
| [Parte 1](01-master-specification.md) | Seções 1–15 e início da seção 16 | Termina em `query` |
| [Parte 2](02-continuation.md) | Seção 16 detalhada, seções 17–44 e início da seção 45 | Termina em `Terraform` |
| [Parte 3](03-final-continuation.md) | Seção 45 completa, seções 46–63 e início da seção 64 | Termina em `consistency` |
| [Parte 4](04-roadmap-and-policies.md) | Seção 64 completa e seções 65–100 | Termina no título `101. FIRST IMPLEMENT` |

A parte 2 complementa a parte 1 e detalha os requisitos de MCP. A parte 3
completa a seção 45 e amplia o currículo. A parte 4 completa a seção 64,
estabelece políticas operacionais e define o roadmap macro na seção 100.
O conteúdo da seção 101, que aparenta definir a primeira implementação,
não foi recebido. O trecho ausente não foi inferido.

## Estado verificado em 27/09/2026

- Diretório da plataforma: `ai-services/ai-platform`, dentro do repositório
  Git `mais-clinical`; não há necessidade de criar um repositório Git aninhado.
- A pasta estava vazia antes do registro desta documentação.
- Nenhum serviço, cluster ou recurso de cloud foi criado.
- Docker, kind, Helm, kubectl, Terraform e Make não foram encontrados no PATH
  da sessão PowerShell. Isso não comprova ausência em outros ambientes, como WSL.
- Inspeção posterior com `wsl.exe --status` e `wsl.exe --list --verbose`:
  executável disponível, versão padrão 2 e nenhuma distribuição instalada.
  Isso ainda não valida a execução de workloads WSL2. Nenhuma distribuição
  ou ferramenta foi instalada durante essa inspeção.
- Python 3.14.7 foi identificado em uma instalação local; existe também Python
  3.12.14 no runtime do aplicativo. A estratégia de desenvolvimento reprodutível
  ainda deve ser definida, sem depender de caminhos privados desse runtime.

## Roadmap macro recebido — seção 100

Este roadmap substitui a sequência preliminar organizada antes da parte 4.
Nenhuma fase está declarada concluída. Cada entrega deve atender à definição
de pronto da seção 98 e registrar o nível real de validação da seção 97.

| Fase | Escopo definido pelo usuário |
| --- | --- |
| 0 — Foundation | Especificação, arquitetura, estrutura de ADRs, dependências, ambiente local, roadmap de aprendizado, matriz de habilidades e referências |
| 1 — Local Platform | Serviço em container, Kubernetes local, Helm, health checks, segurança básica, testes e laboratórios de diagnóstico |
| 2 — Observability + MCP | OpenTelemetry, Prometheus, Grafana, servidores e cliente MCP, testes de segurança |
| 3 — AI Inference | LiteLLM, vLLM quando houver hardware compatível, catálogo de modelos, métricas e benchmarks |
| 4 — GitOps | Argo CD, GitOps, drift, CI e supply chain |
| 5 — RAG + Agents | Ingestão, recuperação, avaliação, Knowledge MCP, runtime de agentes, tool calling e tracing |
| 6 — AWS | Terraform, rede, identidade, EKS, Karpenter, GPU e Spot; recursos pagos exigem aprovação humana |
| 7 — Azure | AKS, deployment equivalente e diferenças documentadas; recursos pagos exigem aprovação humana |
| 8 — Crossplane | Providers, XRD, Composition e API interna de plataforma |
| 9 — Advanced Platform | SRE, FinOps, políticas de segurança, capacity planning, chaos/failure labs e rollout de modelos |
| 10 — Systems Labs | Rust, C++, CUDA e estudos de performance de baixo nível |

Segurança, documentação, testes, observabilidade e custos acompanham cada etapa;
suas etapas específicas aprofundam esses temas, não adiam sua introdução.

## Requisitos incorporados da parte 3

| Seções | Entregável e critério |
| --- | --- |
| 45–49 | Biblioteca de documentação oficial, código-fonte, livros, papers e engenharia de produção; verificar URLs e edições antes de registrá-las; explicar relevância, pré-requisitos e ordem de leitura |
| 46 | Estudo deliberado de diretórios e padrões dos projetos oficiais; comandos de clone opcionais, sem baixar grandes repositórios automaticamente |
| 50 | Progressão de 30 laboratórios de construção e falha; cada laboratório com objetivo, arquitetura, pré-requisitos, comandos, resultado esperado, diagnóstico, cleanup, perguntas e considerações de produção |
| 51–52 | Failure labs com hipóteses e evidências; identificar métricas, logs e traces disponíveis; solução opcional separada do exercício |
| 53 | ADRs com contexto, decisão, alternativas pesquisadas, consequências, riscos e condições de revisão |
| 54–56 | Mapa de conhecimento, matriz de habilidades com níveis 0–5 e perguntas progressivas; respostas separadas; domínio depende de evidência da execução pelo usuário |
| 57–58 | Simulações de incidentes e capacity planning baseados em medições, sem inventar capacidade de produção |
| 59 | Economia de GPU, custo ocioso, Spot, cold start e custos por requisição/token; distinguir estimativas de faturamento real |
| 60 | Comparação de runtimes por metodologia mensurável, sem pontuações arbitrárias nem vencedor universal |
| 61–63 | Trilhas práticas de redes, Linux e internos de containers, ligadas aos diagnósticos de Kubernetes |
| 64 | Sistemas distribuídos; lista completada pela parte 4 |

## Requisitos incorporados da parte 4

| Seções | Entregável e restrições |
| --- | --- |
| 64–66 | Sistemas distribuídos ligados aos componentes, internos de Kubernetes, control loops e scheduler; não implementar consenso próprio para produção |
| 67–70 | GPU/CUDA, memória de inferência, desempenho e paralelismo; medições reproduzíveis, sem clusters caros apenas para cumprir laboratórios |
| 71–75 | Gateway, MCP aprofundado, agentes com estado e controles determinísticos, threat model e RAG com falhas de recuperação e autorização |
| 76–79 | Isolamento futuro de tenants, contratos de API, persistência e caches/filas somente quando houver problema concreto e ADR |
| 80–82 | Onboarding e CONTRIBUTING, self-service após maturidade, backup/restore com RPO/RTO; não instalar Backstage automaticamente |
| 83–89 | Ambientes explícitos, validação de configuração, versões rastreáveis, release/model rollout, prompts versionados e registro de experimentos |
| 90–91 | Aprovação humana antes de recursos pagos e confirmação para operações potencialmente destrutivas |
| 92–96 | Respeitar monorepo e raiz dos workflows; Python principal com ambiente isolado e lockfile; investigar Windows/WSL separadamente; explicar comandos, efeitos, falhas e reversão |
| 97–99 | Evidência real de validação, definição de pronto e entregas verticais pequenas, executáveis e documentadas |
| 100 | Roadmap macro reproduzido acima |
| 101, título apenas | Conteúdo da primeira implementação ainda não recebido |

## Restrições que acompanham todas as entregas

- Não confundir a arquitetura desejada com o estado instalado.
- Não criar diretórios vazios, implementações fictícias ou resultados de benchmark inventados.
- Manter comandos fundamentais visíveis mesmo quando houver atalhos Make.
- Distinguir testes unitários com doubles de integrações reais.
- Testes sem GPU não validam inferência ou comportamento real de GPU.
- Começar MCP com leitura controlada, sem execução arbitrária de shell ou mutações destrutivas.
- Não persistir credenciais, prompts ou respostas sensíveis por padrão.
- Antes de recursos pagos, documentar recurso, região, estimativa de custo, motivo,
  duração, remoção e alternativa local; obter aprovação humana explícita (seção 90).
- Operações potencialmente destrutivas exigem confirmação humana, incluindo
  destroy, exclusão de namespace/banco, rotação de secrets e mudanças de produção (seção 91).
- Usar Python com versão suportada explicitamente, lockfile e ambiente isolado;
  não depender do Python privado de outro aplicativo (seção 94).
- Criar cada módulo de aprendizado junto de uma entrega concreta, com os campos da seção 43.
- Preservar referências como links e notas próprias, sem copiar obras protegidas.
- GitHub Actions deve ficar na raiz Git efetiva (`mais-clinical/.github/workflows`);
  uma pasta `.github/workflows` apenas dentro de `ai-platform` não será descoberta
  automaticamente pelo GitHub. Documentar essa adaptação antes de criar o pipeline.

## Próximo passo

Após o recebimento das quatro partes, o usuário instruiu: “agora execute tudo,
crie esse projeto”. Essa instrução autoriza iniciar com o material disponível,
sem continuar aguardando a seção 101. Os anexos originais permanecem intactos.
O roadmap da seção 100 orienta entregas verticais (seção 99), preservando os
gates de recursos pagos e operações destrutivas (seções 90–91).

Consultar `../../README.md` e `../validation.md` para o estado atual da primeira
entrega. As observações de ambiente acima são o registro anterior à implementação.
