#!/bin/bash
set -e

cd /workspace

echo "[start_embed_rerank] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_embed_rerank] Installing vllm..."
uv pip install vllm --torch-backend=auto

echo "[start_embed_rerank] Starting Qwen3-VL-Embedding-2B on port 8000..."
vllm serve Qwen/Qwen3-VL-Embedding-2B \
  --runner pooling \
  --max-model-len 2048 \
  --dtype auto \
  --hf-overrides '{"matryoshka_dimensions":[1024]}' \
  --port 8000 \
  --gpu-memory-utilization 0.55 &

echo "[start_embed_rerank] Starting Qwen3-VL-Reranker-2B on port 8001..."
vllm serve Qwen/Qwen3-VL-Reranker-2B \
  --runner pooling \
  --dtype auto \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.40 \
  --chat-template /template/qwen3_vl_reranker.jinja \
  --hf-overrides '{"architectures": ["Qwen3VLForSequenceClassification"], "classifier_from_token": ["no", "yes"], "is_original_qwen3_reranker": true}' \
  --port 8001 &

wait -n
