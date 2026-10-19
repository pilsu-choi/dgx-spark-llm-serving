# dgx-spark-llm-serving

Serving LLMs on an **NVIDIA DGX Spark–class machine** (Lenovo ThinkStation PGX, GB10 Grace
Blackwell, aarch64, 128 GB unified memory) with vLLM in Docker, weights on an external SSD.

Everything below was run and measured on the real machine on 2026-10-19.
Companion repo for the physical-AI stack: [dgx-spark-physical-ai](https://github.com/pilsu-choi/dgx-spark-physical-ai).

## Results at a glance

**Qwen3.8-27B NVFP4 + MTP speculative decoding, vLLM 0.31.0, single GB10**

| What | Result |
| --- | --- |
| Single request, code generation, 1024 output tokens, thinking off | **26–30 tok/s** decode, TTFT ~0.2 s |
| MTP draft acceptance (single request, code) | ~80%, mean acceptance length 3.4–3.8 of 4 |
| 8 concurrent requests, random 1000 in / 500 out (`vllm bench serve`) | 116 tok/s total output (70 tok/s on the first, cold run) |
| Weights / KV cache | 22.2 GiB weights, 68.6 GiB fp8 KV cache = 1.78 M tokens |
| Cold start (USB SSD) | ~8 min: 3.5 min weight load + 3.5 min compile / CUDA graphs |

For comparison, community reports put the official FP8 build at ~8 tok/s without MTP and
~17 tok/s with MTP on one Spark. Details: [wiki/runbooks/qwen3.8-27b-nvfp4.md](wiki/runbooks/qwen3.8-27b-nvfp4.md).

## Environment

| Item | Version |
| --- | --- |
| OS | DGX OS 7.2.3 (Ubuntu 24.04, arm64) |
| GPU driver / CUDA | 580.178.04 / CUDA 13.0 |
| Engine | Docker image `vllm/vllm-openai:v0.31.0` (multi-arch, arm64) |
| Model | [`unsloth/Qwen3.8-27B-NVFP4`](https://huggingface.co/unsloth/Qwen3.8-27B-NVFP4) (includes MTP weights) |
| Storage | weights at `/mnt/ssd/models` on an external 2 TB USB SSD |

## Quick start

```bash
# user must be in the docker group, with the nvidia container runtime installed
docker pull vllm/vllm-openai:v0.31.0
uvx --from 'huggingface_hub[hf_xet]' hf download unsloth/Qwen3.8-27B-NVFP4 \
  --local-dir /mnt/ssd/models/Qwen3.8-27B-NVFP4          # 22 GB, ~6 min

./scripts/serve-qwen.sh                                    # container "qwen", port 8000
until curl -sf localhost:8000/v1/models >/dev/null; do sleep 10; done   # ~8 min
python3 scripts/tps.py "Write a quicksort in Rust."        # prints decode tok/s
docker rm -f qwen                                          # stop
```

The endpoint is OpenAI-compatible (`/v1/chat/completions`, also `/v1/messages`), model name
`qwen3.8-27b`. Thinking is on by default; turn it off per request with
`"chat_template_kwargs": {"enable_thinking": false}`.

## Layout

```
scripts/     serve script (docker run + vllm flags) and a single-stream tok/s probe
docs/logs/   raw output the numbers come from
wiki/        knowledge base: runbooks, decisions, lessons, research, open issues, work log
```

Start with the [wiki index](wiki/index.md).

## Gotchas worth knowing up front

- Dense 27B on Spark is **memory-bandwidth bound** (~273 GB/s): bits per weight and speculative
  decoding matter far more than compute. NVFP4 + MTP is the fast path.
- `VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS=0` is set (community recipe); vLLM warns that CUDA
  graph memory is then not reserved, so keep `--gpu-memory-utilization` at 0.80 rather than 0.9+.
- Weights downloaded from inside a container end up root-owned; download as the user instead
  ([lesson](wiki/lessons/download-as-user.md)).
