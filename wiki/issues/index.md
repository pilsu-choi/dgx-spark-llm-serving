---
type: Index
title: Open issues
description: Known gaps and open questions in the serving setup.
tags: [index, issue]
timestamp: 2026-10-19T14:50:00Z
---

# Open issues

- **Quality of NVFP4 vs FP8 not measured.** Only speed was checked. A small eval (coding tasks,
  Korean) against `Qwen/Qwen3.8-27B-FP8` would show what the 4-bit weights cost.
- **`num_speculative_tokens` not tuned.** vLLM warns that >1 reuses the single MTP layer; 3 gave
  ~80% acceptance on code. Try 2 and 4.
- **`VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS=0` may be unnecessary.** With it, CUDA graph memory
  isn't reserved (only 0.17 GiB used in practice). Try removing it on the next restart.
- **Thinking mode not benchmarked.** All numbers are with `enable_thinking: false`.
- **No auth on port 8000.** Fine on the home LAN; add `--api-key` before exposing it anywhere else.
- **Vision input untested.** The checkpoint includes the processor configs; image prompts not tried.
