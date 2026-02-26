#!/bin/bash
set -e

cd /workspace

uv venv --python 3.12 --seed
source .venv/bin/activate
uv pip install vllm --torch-backend=auto

curl -fsSL -o /workspace/qwen3_vl_reranker.jinja \
  https://raw.githubusercontent.com/bojone/mmw_repos/main/mlops_fastapi/template/qwen3_vl_reranker.jinja

exec vllm serve Qwen/Qwen3-VL-Reranker-2B \
  --runner pooling \
  --dtype auto \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.9 \
  --trust-remote-code \
  --chat-template /workspace/qwen3_vl_reranker.jinja \
  --hf-overrides '{"architectures": ["Qwen3VLForSequenceClassification"], "classifier_from_token": ["no", "yes"], "is_original_qwen3_reranker": true}' \
  --port 8001
