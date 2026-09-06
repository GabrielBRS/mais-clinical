FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://pixi.sh/install.sh | bash
ENV PATH="/root/.pixi/bin:${PATH}"
WORKDIR /src
COPY pixi.toml ./
COPY src ./src
COPY tests ./tests
RUN pixi install --locked || pixi install
RUN pixi run build
CMD ["./build/vision-inference-engine"]
