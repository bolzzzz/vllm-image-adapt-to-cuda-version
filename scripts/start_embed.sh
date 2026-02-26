#!/bin/bash
set -e

cd /workspace

uv venv --python 3.12 --seed
source .venv/bin/activate
uv pip install vllm --torch-backend=auto

exec vllm serve Qwen/Qwen3-VL-Embedding-2B \
  --runner pooling \
  --max-model-len 8192 \
  --dtype auto \
  --trust-remote-code \
  --hf-overrides '{"matryoshka_dimensions":[1024]}' \
  --port 8000 \
  --gpu-memory-utilization 0.9
