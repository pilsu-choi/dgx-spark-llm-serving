---
type: Research
title: Qwen3.8-27B on DGX Spark
description: Available checkpoints, serving recipes and community-reported speeds for Qwen3.8-27B on one or more Sparks.
tags: [research, qwen, vllm, benchmark]
timestamp: 2026-10-19T14:50:00Z
---

# Qwen3.8-27B on DGX Spark

Collected 2026-10-19. Community numbers are self-reported, not controlled.

## Checkpoints

| Repo | Format | Size | Notes |
| --- | --- | --- | --- |
| `Qwen/Qwen3.8-27B` | BF16 | ~52 GB | |
| `Qwen/Qwen3.8-27B-FP8` | FP8 e4m3, block 128 | ~31 GB | official |
| `unsloth/Qwen3.8-27B-NVFP4` | NVFP4, FP8 KV | ~23 GB | MTP head in `model_mtp.safetensors` — **used here** |
| `nvidia/Qwen3.8-27B-NVFP4` | NVFP4 (ModelOpt) | | |
| `Inferact/Qwen3.8-27B-NVFP4` | NVFP4 | | vLLM recipe default |
| MixedInt4 AutoRound (community) | INT4 mixed | ~21 GB | built for a single Spark, MTP included |

## Reported speeds

| Setup | Single-request decode | Source |
| --- | --- | --- |
| FP8, 1 Spark, no MTP | ~8 tok/s | NVIDIA forum study, user report |
| FP8, 1 Spark, MTP n=3 | ~17 tok/s | NVIDIA forum study |
| NVFP4 vs FP8, 1 Spark, vLLM 0.27.1 | NVFP4 +29–34% throughput | NVIDIA forum |
| 2 Sparks TP / 4 Sparks | ~52 / ~77 tok/s | NVIDIA forum study |
| **NVFP4 + MTP n=3, 1 Spark, vLLM 0.31.0** | **26–30 tok/s** | *measured here* |

## Recipes

- vLLM recipe: TP 1 on any single Blackwell, `--kv-cache-dtype fp8`, `--reasoning-parser qwen3`,
  `--tool-call-parser qwen3_coder`, MTP with 3 speculative tokens.
- Forum FP8 recipe on Spark adds `VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS=0`,
  `--max-num-batched-tokens 8192`, `--enable-chunked-prefill`, `--gpu-memory-utilization 0.88`.
  Its post contains curly quotes and en-dashes that break when pasted into a shell.

## Sources

- [vLLM recipe: Qwen3.8-27B](https://recipes.vllm.ai/Qwen/Qwen3.8-27B)
- [SGLang cookbook: Qwen3.8-27B](https://lmsysorg.mintlify.app/cookbook/autoregressive/Qwen/Qwen3.8-27B)
- [NVIDIA forum: NVFP4 vs FP8 on DGX Spark](https://forums.developer.nvidia.com/t/qwen3-8-27b-on-dgx-spark-using-vllm-nvfp4-vs-fp8-performance/380258)
- [NVIDIA forum: Comprehensive Qwen3.8-27B study on DGX Sparks](https://forums.developer.nvidia.com/t/comprehensive-qwen3-8-27b-study-on-dgx-sparks-quantization-speculative-decoding-and-tp-dp-scaling/381102)
- [NVIDIA forum: MixedInt4 AutoRound for a single Spark](https://forums.developer.nvidia.com/t/qwen3-8-27b-mixedint4-autoround-optimized-for-a-single-dgx-spark/380248)
