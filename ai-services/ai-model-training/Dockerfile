FROM ghcr.io/prefix-dev/pixi:0.79.0

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc g++ \
    && rm -rf /var/lib/apt/lists/*

COPY pixi.toml pixi.lock pyproject.toml uv.lock README.md ./
COPY src ./src
COPY tests ./tests
COPY configs ./configs
COPY recipes ./recipes
COPY data/sft/sample.jsonl ./data/sft/sample.jsonl
COPY data/preference/chosen_rejected/sample.jsonl ./data/preference/chosen_rejected/sample.jsonl
COPY data/pretraining/sample.jsonl ./data/pretraining/sample.jsonl
COPY data/evaluation/golden/sample.jsonl ./data/evaluation/golden/sample.jsonl

RUN pixi install --frozen \
    && pixi run build \
    && pixi run test-contract \
    && pixi run test-mojo

ENV MOJO_PYTHON=/app/.pixi/envs/default/bin/python \
    MOJO_PYTHON_LIBRARY=/app/.pixi/envs/default/lib/libpython3.13.so \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

ENTRYPOINT ["/app/build/ai-model-training"]
CMD ["health"]
