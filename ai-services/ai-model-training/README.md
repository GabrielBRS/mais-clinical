# AI Model Training

Host de aplicação em Mojo para preparação de dados, treinamento, avaliação,
exportação e publicação de modelos. O entrypoint operacional é o binário
`build/ai-model-training`.

## Arquitetura real

```text
binário Mojo
  → CPython hospedado no mesmo processo
  → llm_adaptation.host_api
  → pipeline Python
  → engine/modelo e bibliotecas nativas
```

O Mojo não compila Python, PyTorch ou pacotes Python para dentro do binário. O
runtime CPython e o pacote `llm_adaptation` são dependências de execução,
gerenciadas junto com Mojo pelo Pixi.

O engine atual do repositório ainda é um modelo dummy de CPU usado como scaffold
determinístico. PyTorch, Transformers, PEFT, Accelerate, DeepSpeed e GPU não
estão instalados nem validados. Recipes de DPO, GRPO, continued pretraining e
distributed são preservadas, mas ainda não representam treinamento real desses
métodos.

## Setup e build

```bash
pixi install --frozen
pixi run test
pixi run build
```

O build liga o executável a `libpython3.13`, mas continua dependendo do ambiente
Pixi em runtime.

## CLI Mojo

```bash
pixi run ai-model-training health
pixi run ai-model-training prepare-data --recipe recipes/qwen/sft_lora.yaml
pixi run ai-model-training train --recipe recipes/qwen/sft_lora.yaml
pixi run ai-model-training evaluate --recipe recipes/qwen/sft_lora.yaml
pixi run ai-model-training export --recipe recipes/qwen/sft_lora.yaml
pixi run ai-model-training publish --recipe recipes/qwen/sft_lora.yaml
```

Opções compartilhadas: `--root`, `--device`, `--dry-run` e, para treino,
`--resume`. O catálogo de operações é fechado; a CLI não aceita nomes de módulo
ou função Python.

Os wrappers em `scripts/` e o console script Python `llm-adaptation` permanecem
somente para baseline e compatibilidade durante a migração.

## Contrato e segurança

Requests e resultados usam `schema_version: "1.0"`. Recipes são restritas ao
diretório `recipes/`, fragments ao diretório `configs/` e dados ao diretório
`data/`. Overrides permanecem desativados até existir uma allowlist explícita.
Erros Python são devolvidos como JSON normalizado e produzem código de saída não
zero no binário.

Detalhes: [limite Mojo–Python](docs/architecture/mojo-python-boundary.md) e
[arquitetura](docs/architecture/overview.md).

## Testes e benchmark

```bash
pixi run test-python
pixi run test-contract
pixi run test-mojo
pixi run test-integration
pixi run benchmark
```

Os testes usam raízes temporárias e não escrevem em `artifacts/` ou `data/` do
workspace. A integração usa `strace`, quando disponível, para confirmar que o
fluxo normal do binário não inicia um subprocesso Python.

## Container de job

```bash
docker build -t ai-model-training:local .
docker run --rm ai-model-training:local health
```

O entrypoint do container é o binário Mojo. Monte datasets e artefatos como
volumes em execuções reais; não inclua tokens, credenciais, pesos ou datasets
privados na imagem.
