# Specs deste projeto

Coloque aqui os `.md` de especificação do **ai-compute-engine**. O agente deve lê-los antes de implementar qualquer componente.

## Como adicionar

1. Copie `_TEMPLATE.md` para um nome numerado, por exemplo `02-runtime.md`.
2. Preencha objetivo, comportamento, fora de escopo, interfaces e critérios de aceite.
3. Peça para implementar — o agente deve abrir as specs antes de alterar o código.

Não edite este `README.md` nem arquivos que começam com `_`; eles não são specs executáveis.

## Convenção de nomes

```text
01-core.md
02-runtime.md
03-gpu-kernels.md
04-inference.md
05-transport.md
```

O número define a ordem de prioridade quando duas specs se sobrepõem.

Este repositório é **Mojo-only**. Specs descrevem comportamento e contrato, não pedem C++/CUDA.
