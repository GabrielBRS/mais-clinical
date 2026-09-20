# Arquitetura

O único entrypoint operacional é `src/main.mojo`, compilado como
`build/ai-model-training`. Ele valida a CLI, gera o `run_id`, inicializa CPython
no mesmo processo e importa a fachada conhecida `llm_adaptation.host_api`.

```text
CLI Mojo
  → request tipado do host
  → registry de operações permitido
  → CPython no processo Mojo
  → fachada Python versionada
  → prepare | train | evaluate | export | publish
  → resultado e erro normalizados
```

A CLI é um adapter. Os casos de uso e o contrato não dependem de HTTP; um futuro
adapter HTTP deverá criar jobs assíncronos por operação registrada, nunca manter
uma conexão aberta durante o treinamento nem aceitar código Python arbitrário.

O domínio de modelagem permanece em Python. Mojo só deve receber compute quando
profiling, testes de correção e benchmark demonstrarem benefício.

Veja [o contrato de interoperabilidade](mojo-python-boundary.md).
