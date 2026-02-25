FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl ca-certificates build-essential && rm -rf /var/lib/apt/lists/*

RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_VENV_CLEAR=1

WORKDIR /workspace

CMD ["tail", "-f", "/dev/null"]
