#!/bin/bash
set -e

cd /workspace

echo "[start_document_parser] Creating venv..."
uv venv --python 3.12 --seed
source .venv/bin/activate

echo "[start_document_parser] Installing vllm==0.16.0..."
uv pip install "vllm==0.16.0" "nvidia-cuda-runtime-cu12" torch-c-dlpack-ext --torch-backend=auto

# Ensure libcudart.so.12 from the Python runtime package is discoverable.
CUDA_RT_LIB_DIR="$(python -c 'import nvidia.cuda_runtime as m, os; print(os.path.join(next(iter(m.__path__)), "lib"))')"
export LD_LIBRARY_PATH="${CUDA_RT_LIB_DIR}:${LD_LIBRARY_PATH}"

echo "[start_document_parser] Starting markmywords-au/document_parser_grpo_v1 on port 8000..."
exec vllm serve markmywords-au/document_parser_grpo_v1 \
  --max-model-len 8192 \
  --port 8000 \
  --enable-lora \
  --lora-modules page_rotation=markmywords-au/document_parser-page_rotation \
  --enforce-eager
