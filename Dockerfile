FROM ubuntu/python:3.12-24.04_stable

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv

ENV UV_SYSTEM_PYTHON=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/usr/local

# Auto-select torch backend from host/GPU environment while installing vLLM.
RUN uv pip install vllm==0.15.1 --torch-backend=auto

COPY entrypoint.sh /entrypoint.sh

EXPOSE 8000 8001

ENTRYPOINT ["/entrypoint.sh"]
