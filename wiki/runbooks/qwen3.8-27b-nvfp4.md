---
type: Runbook
title: Qwen3.8-27B NVFP4 on vLLM
description: Serving Qwen3.8-27B (NVFP4, MTP speculative decoding) on a single GB10 with vLLM in Docker, with measured performance.
tags: [qwen, vllm, nvfp4, mtp, benchmark]
timestamp: 2026-10-19T14:50:00Z
---

# Qwen3.8-27B NVFP4 on vLLM

Qwen3.8-27B is a dense 27B multimodal model (64 layers, hidden 5120, hybrid attention, 262K native
context). The NVFP4 build is ~22 GB, which leaves ~70 GB of unified memory for KV cache.

## Prerequisites

- User in the `docker` group, nvidia container runtime installed (`docker info | grep -i runtime`
  shows `nvidia`).
- ~25 GB for the image on the internal disk (`/var/lib/docker`), 22 GB for weights on the SSD.

## Download

```bash
docker pull vllm/vllm-openai:v0.31.0          # 23.9 GB, multi-arch
uvx --from 'huggingface_hub[hf_xet]' hf download unsloth/Qwen3.8-27B-NVFP4 \
  --local-dir /mnt/ssd/models/Qwen3.8-27B-NVFP4
```

Files: `model.safetensors` (22.6 GB), `model_mtp.safetensors` (0.85 GB, the MTP draft head),
tokenizer, chat template, processor configs. Not gated.

## Serve

[scripts/serve-qwen.sh](../../scripts/serve-qwen.sh) runs a detached container `qwen` on port 8000.
Extra arguments are appended to `vllm serve`.

| Flag | Value | Why |
| --- | --- | --- |
| `--speculative-config` | `{"method":"mtp","num_speculative_tokens":3}` | Biggest single speed-up on a bandwidth-bound dense model; vLLM recipe value |
| `--kv-cache-dtype` | `fp8` | Halves KV memory and bandwidth |
| `--max-model-len` | 131072 | Native is 262144; 128K is plenty and keeps per-request reservation sane |
| `--max-num-seqs` | 8 | Small team / agent use, not batch serving |
| `--max-num-batched-tokens` | 8192 | Chunked-prefill chunk size from the community recipe |
| `--gpu-memory-utilization` | 0.80 | Unified memory is shared with the OS and the CPU side |
| `--reasoning-parser` | `qwen3` | Splits `<think>` into `reasoning_content` |
| `--tool-call-parser` | `qwen3_coder` + `--enable-auto-tool-choice` | Tool calling for agents |
| `VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS` | 0 | From the community FP8 recipe; see [issue](../issues/index.md) |

vLLM picks up the quantization automatically (`compressed-tensors`) and uses the FlashInfer
attention backend.

Startup (*measured*, cold, USB SSD): weights 205 s (22.18 GiB), then KV profiling, `torch.compile`
(37 s) and CUDA graph capture for target and draft model; ready at 460 s. Raw log:
[docs/logs/vllm-qwen3.8-27b-nvfp4-startup-2026-10-19.txt](../../docs/logs/vllm-qwen3.8-27b-nvfp4-startup-2026-10-19.txt).

## Test

```bash
curl -s localhost:8000/v1/models
python3 scripts/tps.py "한국어로 한 문장 자기소개 해줘."
```

[scripts/tps.py](../../scripts/tps.py) streams one chat completion (max 1024 tokens, thinking off)
and prints TTFT and decode tok/s.

## Measured performance

| Test | Result |
| --- | --- |
| Single request, code prompt, 1024 tokens (5 runs) | 26.3, 27.9, 29.0, 29.8, 30.5 tok/s; TTFT 0.19–0.22 s |
| MTP acceptance, single request, code | 80–81% avg; per position ~0.90 / 0.79 / 0.72; mean acceptance length 3.4–3.8 |
| Short Korean answer (27 tokens) | 16.5 tok/s (too short for MTP to pay off) |
| `vllm bench serve`, random 1000 in / 500 out, 16 prompts, concurrency 8, cold | 70.4 tok/s output, mean TTFT 3.5 s, mean TPOT 71 ms |
| Same, warm | 116.2 tok/s output, mean TTFT 2.8 s, mean TPOT 53 ms, acceptance 64% |

Random-token prompts are a worst case for MTP (lower acceptance); real chat and code traffic will
sit between the two rows. Raw output: [single-stream](../../docs/logs/single-stream-2026-10-19.txt),
[bench](../../docs/logs/bench-c8-random-2026-10-19.txt).

Memory at steady state: 25.3 GiB weights + non-torch, 1.8 GiB peak activation, 0.17 GiB CUDA
graphs, 68.6 GiB KV cache (1,785,011 tokens; 13.6× full 128K requests).

## Operations

```bash
docker logs -f qwen | grep -v /metrics       # follow
docker logs qwen 2>&1 | grep SpecDecoding     # acceptance rate every 10 s
docker rm -f qwen                             # stop and free ~95 GB
```

The container has `--restart no`: it does not come back after a reboot, by design, so it doesn't
hold 95 GB while other workloads (Isaac, GR00T fine-tunes) need the memory.
