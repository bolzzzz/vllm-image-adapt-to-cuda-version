#!/bin/bash
set -e

cd /workspace

echo "[start_embed_rerank] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_embed_rerank] Installing vllm..."
uv pip install vllm torch-c-dlpack-ext --torch-backend=auto

echo "[start_embed_rerank] Starting Qwen3-VL-Embedding-2B on port 8000..."
vllm serve Qwen/Qwen3-VL-Embedding-2B \
  --runner pooling \
  --max-model-len 768 \
  --dtype auto \
  --hf-overrides '{"matryoshka_dimensions":[1024]}' \
  --port 8000 \
  --gpu-memory-utilization 0.40 &
embed_pid=$!

echo "[start_embed_rerank] Waiting for Embedding API on port 8000..."
until bash -c "exec 3<>/dev/tcp/127.0.0.1/8000" 2>/dev/null; do
  if ! kill -0 "$embed_pid" 2>/dev/null; then
    echo "[start_embed_rerank] Embedding process exited before becoming ready."
    wait "$embed_pid"
    exit 1
  fi
  sleep 2
done

echo "[start_embed_rerank] Starting Qwen3-VL-Reranker-2B on port 8001..."
vllm serve Qwen/Qwen3-VL-Reranker-2B \
  --runner pooling \
  --dtype auto \
  --max-model-len 768 \
  --gpu-memory-utilization 0.45 \
  --chat-template /template/qwen3_vl_reranker.jinja \
  --hf-overrides '{"architectures": ["Qwen3VLForSequenceClassification"], "classifier_from_token": ["no", "yes"], "is_original_qwen3_reranker": true}' \
  --port 8001 &
rerank_pid=$!

echo "[start_embed_rerank] Waiting for Reranker API on port 8001..."
until bash -c "exec 3<>/dev/tcp/127.0.0.1/8001" 2>/dev/null; do
  if ! kill -0 "$rerank_pid" 2>/dev/null; then
    echo "[start_embed_rerank] Reranker process exited before becoming ready."
    wait "$rerank_pid"
    exit 1
  fi
  sleep 2
done

echo "[start_embed_rerank] Ready: Embedding (8000) and Reranker (8001) are both up."

wait -n "$embed_pid" "$rerank_pid"
