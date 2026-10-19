#!/usr/bin/env bash
# Qwen3.8-27B NVFP4 + MTP on vLLM (single GB10). Usage: serve-qwen.sh [extra vllm args]
set -euo pipefail
docker rm -f qwen >/dev/null 2>&1 || true
exec docker run -d --name qwen --gpus all --ipc=host --restart no \
  -p 8000:8000 \
  -v /mnt/ssd/models:/models:ro \
  -v /mnt/ssd/cache/vllm:/root/.cache/vllm \
  -e VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS=0 \
  vllm/vllm-openai:v0.31.0 \
  /models/Qwen3.8-27B-NVFP4 \
  --served-model-name qwen3.8-27b \
  --tensor-parallel-size 1 \
  --kv-cache-dtype fp8 \
  --max-model-len 131072 \
  --max-num-seqs 8 \
  --max-num-batched-tokens 8192 \
  --gpu-memory-utilization 0.80 \
  --enable-chunked-prefill \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3}' \
  --reasoning-parser qwen3 \
  --enable-auto-tool-choice --tool-call-parser qwen3_coder \
  "$@"
