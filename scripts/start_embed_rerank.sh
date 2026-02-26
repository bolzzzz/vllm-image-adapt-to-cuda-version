#!/bin/bash
set -e

cd /workspace

# 共用一个 venv
uv venv --python 3.12 --seed
source .venv/bin/activate
uv pip install vllm --torch-backend=auto

curl -fsSL -o /workspace/qwen3_vl_reranker.jinja \
  https://raw.githubusercontent.com/bojone/mmw_repos/main/mlops_fastapi/template/qwen3_vl_reranker.jinja

# embed (port 8000)
vllm serve Qwen/Qwen3-VL-Embedding-2B \
  --runner pooling \
  --max-model-len 8192 \
  --dtype auto \
  --trust-remote-code \
  --hf-overrides '{"matryoshka_dimensions":[1024]}' \
  --port 8000 \
  --gpu-memory-utilization 0.45 &

# rerank (port 8001)
vllm serve Qwen/Qwen3-VL-Reranker-2B \
  --runner pooling \
  --dtype auto \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.45 \
  --trust-remote-code \
  --chat-template /workspace/qwen3_vl_reranker.jinja \
  --hf-overrides '{"architectures": ["Qwen3VLForSequenceClassification"], "classifier_from_token": ["no", "yes"], "is_original_qwen3_reranker": true}' \
  --port 8001 &

wait -n
