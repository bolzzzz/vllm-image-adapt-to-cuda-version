FROM ghcr.io/astral-sh/uv:0.10.6 AS uv

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl ca-certificates build-essential && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_VENV_CLEAR=1

WORKDIR /workspace

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

CMD ["tail", "-f", "/dev/null"]
