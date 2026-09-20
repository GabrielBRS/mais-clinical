# Limite Mojo–Python

## Runtime

`src/host/interop/python_runtime.mojo` usa a interoperabilidade oficial
`Python.import_module()`. Não existe `subprocess`, `eval`, `exec`, descoberta de
arquivos ou import controlado pelo cliente.

O executável liga `libpython3.13` e precisa das variáveis `MOJO_PYTHON` e
`MOJO_PYTHON_LIBRARY`. O Pixi e o container definem ambas.

## Registry

Operações permitidas:

- `health`;
- `prepare_data` (`prepare-data` na CLI);
- `train`;
- `evaluate`;
- `export`;
- `publish`.

O request `1.0` contém `operation`, `run_id`, `recipe_path`, `root`, `overrides`,
`input_dir`, `output_dir`, `device`, `distributed`, `resume` e `dry_run`.

O resultado `1.0` contém `run_id`, `operation`, `status`, timestamps, métricas,
artefatos, checkpoint, warnings, dados da operação e erro normalizado.

## Segurança

- recipe deve estar dentro de `recipes/`;
- fragments devem estar dentro de `configs/`;
- caminhos de dados devem estar dentro de `data/`;
- overrides estão desativados;
- plugins e uploads de Python não são aceitos;
- módulos Python são código confiável com os mesmos privilégios do processo.

Antes de oferecer execução HTTP multiusuário serão necessários autenticação,
fila persistente, isolamento por worker/container, quotas e política explícita
para código confiável.
