#!/bin/bash
set -e

cd /workspace

echo "[start_rerank] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_rerank] Installing vllm..."
uv pip install vllm torch-c-dlpack-ext --torch-backend=auto

echo "[start_rerank] Starting Qwen3-VL-Reranker-2B on port 8001..."
exec vllm serve Qwen/Qwen3-VL-Reranker-2B \
  --runner pooling \
  --dtype auto \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.9 \

  --chat-template /template/qwen3_vl_reranker.jinja \
  --hf-overrides '{"architectures": ["Qwen3VLForSequenceClassification"], "classifier_from_token": ["no", "yes"], "is_original_qwen3_reranker": true}' \
  --port 8001
