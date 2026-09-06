# Título

Status: rascunho | aceite | feito

## Objetivo

O que este pedaço da plataforma precisa fazer.

## Comportamento

- …

## Fora de escopo

- …

## Interfaces

Pacotes/módulos Mojo, tipos, funções públicas, CLI, IPC/gRPC/HTTP, arquivos/configuração, contrato de dados e, quando aplicável, alvo CPU/GPU que o componente precisa expor.

## Ownership e recursos

Quem possui buffers/objetos/handles, quais referências são emprestadas, quando há transferência de ownership e como recursos CPU/GPU/I/O são liberados.

## Execução e hardware

- CPU escalar | SIMD | GPU | híbrido
- Portável | NVIDIA específico | AMD específico | outro
- Restrições de memória, layout, sincronização ou precisão numérica

## Critérios de aceite

- [ ]

## Testes

- Casos funcionais:
- Casos de erro/borda:
- Tolerância numérica, se aplicável:
- Comparação CPU/GPU ou entre backends, se aplicável:

## Performance

Workload representativo, métrica de latência/throughput e baseline que deve ser medido. Não exigir ganho de performance sem benchmark reproduzível.

## Notas de toolchain

Usar **Mojo 1.0+ estável** e APIs verificadas na documentação oficial ou na versão instalada. Não usar sintaxe/API de tutorial antigo. Recursos nightly/experimentais/MAX instáveis devem ser marcados explicitamente e justificados. Ambiente: **pixi**.
