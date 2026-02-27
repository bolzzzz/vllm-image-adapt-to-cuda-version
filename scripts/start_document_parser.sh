#!/bin/bash
set -e

cd /workspace

echo "[start_document_parser] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_document_parser] Installing vllm==0.10.1.1..."
uv pip install vllm==0.10.1.1 torch-c-dlpack-ext --torch-backend=auto

echo "[start_document_parser] Starting markmywords-au/document_parser_grpo_v1 on port 80..."
exec vllm serve markmywords-au/document_parser_grpo_v1 \
  --max-model-len 8192 \
  --port 8000 \
  --enable-lora \
  --lora-modules page_rotation=markmywords-au/document_parser-page_rotation \
  --gpu-memory-utilization 0.25
