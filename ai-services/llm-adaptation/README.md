# llm-adaptation

Adaptação de LLMs: preparação de dados, SFT, LoRA/QLoRA, continued
pretraining, DPO e GRPO. O treino real de GPU entra pelos adapters
(`training/`); o núcleo roda em CPU com um modelo dummy para testes,
receitas e o pipeline `prepare → train → evaluate → export → publish`.

## Recipes

| Família | Métodos |
| --- | --- |
| Qwen | SFT full/LoRA/QLoRA, CPT, DPO, GRPO |
| Llama | SFT full/LoRA/QLoRA, DPO, GRPO |
| Mistral | mesmo conjunto |
| Nemotron | mesmo conjunto |

Configs fragmentadas em `configs/{model,data,training,distributed,evaluation}`.
Uma recipe só faz `extends` e overlay.

## Run

```bash
uv sync
uv run pytest
uv run llm-adaptation prepare --recipe recipes/qwen/sft_lora.yaml
uv run llm-adaptation train --recipe recipes/qwen/sft_lora.yaml
just test
```

Prefixo de ambiente: `LLA_*`.
