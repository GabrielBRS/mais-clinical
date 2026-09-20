FROM ghcr.io/prefix-dev/pixi:0.79.0@sha256:80a5b1e06fa988cc22554e8bf9e6b4bae87597771c568873691335667055c87d AS builder

RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pixi.toml pixi.lock ./
RUN pixi install --locked

COPY src ./src
RUN pixi run build

FROM ubuntu:24.04@sha256:008173c23f95b170204355c12626cb5a965d779a7e1283b09e9cffbb1bf33ca3 AS runtime

LABEL org.opencontainers.image.title="AI Native Mojo Agent Runtime" \
      org.opencontainers.image.description="Internal-only agentic runtime; public ingress is Rust"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system agent-runtime \
    && useradd --system --gid agent-runtime --no-create-home agent-runtime

COPY --from=builder /app/build/agentd /usr/local/bin/mojo-agent-runtime
COPY --from=builder /app/.pixi/envs/default/lib/libKGENCompilerRTShared.so /usr/local/lib/
COPY --from=builder /app/.pixi/envs/default/lib/libMSupportGlobals.so /usr/local/lib/
COPY --from=builder /app/.pixi/envs/default/lib/libAsyncRTRuntimeGlobals.so /usr/local/lib/
COPY --from=builder /app/.pixi/envs/default/lib/libstdc++.so.6* /usr/local/lib/
COPY --from=builder /app/.pixi/envs/default/lib/libgcc_s.so.1 /usr/local/lib/

ENV LD_LIBRARY_PATH=/usr/local/lib \
    AOR_AGENT_HTTP_HOST=0.0.0.0 \
    AOR_AGENT_HTTP_PORT=8090

USER agent-runtime

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD ["bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/8090; printf 'GET /health/ready HTTP/1.1\\r\\nHost: localhost\\r\\nConnection: close\\r\\n\\r\\n' >&3; grep -q 'HTTP/1.1 200' <&3"]

ENTRYPOINT ["/usr/local/bin/mojo-agent-runtime"]
