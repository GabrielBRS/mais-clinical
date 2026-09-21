FROM rust:1.97-bookworm@sha256:0e2bcaef56d041a486784e54104a81aebe0da44bd03019bd70bc0401e42e4a97 AS builder

RUN apt-get update \
    && apt-get install --yes --no-install-recommends protobuf-compiler=3.21.12-3+deb12u1 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY Cargo.toml Cargo.lock ./
COPY build.rs ./build.rs
COPY proto ./proto
COPY src ./src
RUN cargo build --locked --release -p ai-native-runtime

FROM debian:bookworm-slim@sha256:3783cc01769c7b2b1b83a5c5ad96c815348e28ed7da68e2e3687004faa906251 AS runtime

RUN groupadd --system runtime \
    && useradd --system --gid runtime --no-create-home runtime
COPY --from=builder /workspace/target/release/ai-native-runtime /usr/local/bin/ai-native-runtime

ENV AOR_HTTP_HOST=0.0.0.0 \
    AOR_HTTP_PORT=8080 \
    AOR_LOG_LEVEL=info \
    AOR_AGENT_RUNTIME_URL=http://ai-agent-runtime:8090
EXPOSE 8080
USER runtime
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/usr/local/bin/ai-native-runtime", "--healthcheck"]
ENTRYPOINT ["/usr/local/bin/ai-native-runtime"]
