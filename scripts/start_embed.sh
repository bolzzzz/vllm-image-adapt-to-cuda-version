#!/bin/bash
set -e

cd /workspace

echo "[start_embed] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_embed] Installing vllm..."
uv pip install vllm --torch-backend=auto

echo "[start_embed] Starting Qwen3-VL-Embedding-2B on port 8000..."
exec vllm serve Qwen/Qwen3-VL-Embedding-2B \
  --runner pooling \
  --max-model-len 8192 \
  --dtype auto \

  --hf-overrides '{"matryoshka_dimensions":[1024]}' \
  --port 8000 \
  --gpu-memory-utilization 0.9
