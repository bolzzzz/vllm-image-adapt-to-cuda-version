# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo builds and publishes a Docker image (`bolz213/ubuntu-uv`) that provides a base environment for running vLLM embedding and reranking servers on RunPod (or any container host with NVIDIA GPUs).

## Image

- **Base**: `ubuntu:22.04`
- **uv**: installed via multi-stage copy from `ghcr.io/astral-sh/uv:<version>` — do NOT use the `curl | sh` install method
- **Tag convention**: `ubuntu22.04-uv<uv-version>` (e.g. `ubuntu22.04-uv0.10.6`) plus a floating `ubuntu22.04-uv` tag

## Build & Push

```bash
docker build -t bolz213/ubuntu-uv:ubuntu22.04-uv<VERSION> -t bolz213/ubuntu-uv:ubuntu22.04-uv .
docker push bolz213/ubuntu-uv:ubuntu22.04-uv<VERSION>
docker push bolz213/ubuntu-uv:ubuntu22.04-uv
```

## Scripts

Scripts are baked into the image at `/scripts/` and are `chmod +x`. They are the RunPod **Start Command** entry points:

| Script | Models served | Ports | GPU utilization |
|---|---|---|---|
| `start_embed.sh` | Qwen3-VL-Embedding-2B | 8000 | 0.9 |
| `start_rerank.sh` | Qwen3-VL-Reranker-2B | 8001 | 0.9 |
| `start_embed_rerank.sh` | both | 8000 + 8001 | 0.45 each |

Each script: creates a venv at `/workspace/.venv`, installs vllm, then launches the server(s). The dual script shares one venv and runs both processes in parallel with `wait -n`.

**RunPod Start Command**: use the absolute path, e.g. `/scripts/start_embed_rerank.sh`

## Docker Compose Files

The three `.yml` files in the repo root are the original compose-based references that the scripts were derived from. They are not used for deployment — RunPod runs a single container directly.
