# ADR 0002 — Rust ingress único e Mojo agent runtime interno

Status: aceito

## Contexto

Separar backend tradicional e backend agentic em aplicações independentes cria
duplicação de domínio, dados, autenticação, operação e ownership da resposta.
Também força escolhas prematuras: um backend convencional pode ganhar agentes,
e um produto agentic continua precisando de fluxos convencionais.

## Decisão

O AI Native Application Server é um único produto composto por dois processos:

- Rust é o Application Server completo e o único ingress público;
- Mojo é o runtime agentic interno, incluído em todo projeto e invocado somente
  por casos de uso Rust que precisem de comportamento agentic.

As seguintes invariantes são obrigatórias:

1. clientes nunca acessam Mojo diretamente;
2. Rust autentica, autoriza e valida antes de qualquer chamada agentic;
3. um fluxo tradicional não atravessa Mojo;
4. agentes, nós, graph, orchestration, workflows, tools, RAG/retrieval e AI
   compute pertencem a Mojo;
5. CRUD, domínio de negócio, transações, persistência e integrações tradicionais
   pertencem a Rust;
6. Rust mantém ownership da resposta pública e dos erros expostos ao cliente;
7. o transporte Rust/Mojo é interno e substituível;
8. a indisponibilidade do Mojo afeta capacidades agentic, não a readiness dos
   fluxos tradicionais.

## Consequências

Todo deploy inclui ambos os executáveis, mas somente Rust publica porta. Casos
de uso agentic recebem explicitamente a porta `AgentRuntime`; outros casos de
uso não conhecem Mojo. O runtime Mojo pode permanecer ocioso até a primeira
invocação sem inserir custo ou acoplamento nos fluxos convencionais.

