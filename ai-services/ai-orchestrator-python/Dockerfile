FROM python:3.13-slim
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:0.12.1 /uv /bin/uv
COPY pyproject.toml uv.lock ./
COPY src ./src
COPY config ./config
COPY proto ./proto
RUN uv sync --frozen --no-dev
EXPOSE 8080 50051
CMD ["uv", "run", "ai-orchestrator-python"]
