FROM python:3.13-slim
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:0.12.1 /uv /bin/uv
COPY pyproject.toml uv.lock ./
COPY src ./src
COPY configs ./configs
COPY recipes ./recipes
RUN uv sync --frozen --no-dev
ENTRYPOINT ["uv", "run", "llm-adaptation"]
