FROM ghcr.io/prefix-dev/pixi:0.79.0

WORKDIR /app
COPY pixi.toml pixi.lock ./
RUN pixi install --locked

COPY src ./src
RUN pixi run build

EXPOSE 8080
CMD ["pixi", "run", "./build/agentd"]
