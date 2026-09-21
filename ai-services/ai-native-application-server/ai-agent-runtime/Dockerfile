FROM ghcr.io/prefix-dev/pixi:0.79.0@sha256:80a5b1e06fa988cc22554e8bf9e6b4bae87597771c568873691335667055c87d

LABEL org.opencontainers.image.title="AI Agent Runtime" \
      org.opencontainers.image.description="Internal Mojo runtime that loads the Python AI agent contract"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system agent-runtime \
    && useradd --system --gid agent-runtime --no-create-home agent-runtime

WORKDIR /app/ai-agent-runtime
COPY ai-agent-runtime/pixi.toml ai-agent-runtime/pixi.lock ./
COPY pyproject.toml README.md /app/
COPY ai-agent-contract /app/ai-agent-contract
COPY ai-agent-runtime/src ./src
RUN pixi install --locked \
    && pixi run build

ENV MOJO_PYTHON=/app/ai-agent-runtime/.pixi/envs/default/bin/python \
    MOJO_PYTHON_LIBRARY=/app/ai-agent-runtime/.pixi/envs/default/lib/libpython3.13.so \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    AOR_CONTRACT_ROOT=/app/ai-agent-contract \
    AOR_AGENT_HTTP_HOST=0.0.0.0 \
    AOR_AGENT_HTTP_PORT=8090

USER agent-runtime

HEALTHCHECK --interval=10s --timeout=3s --start-period=15s --retries=3 \
    CMD ["bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/8090; printf 'GET /health/ready HTTP/1.1\\r\\nHost: localhost\\r\\nConnection: close\\r\\n\\r\\n' >&3; grep -q 'HTTP/1.1 200' <&3"]

ENTRYPOINT ["/app/build/agentd"]
