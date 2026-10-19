---
type: Log
title: Work log
description: Chronological history of the serving work, newest last.
tags: [log, history]
timestamp: 2026-10-19T14:50:00Z
---

# Work log

Times are UTC. Each entry links to the page with the details.

## 2026-10-19

- **13:30** Checked whether Qwen3.8-27B FP8 fits a single Spark: yes on memory (~31 GB weights),
  but community numbers put it at ~8 tok/s (≈17 with MTP). Chose NVFP4 for speed
  ([research](research/qwen3.8-27b-on-spark.md), [decision](decisions/nvfp4-over-fp8.md)).
- **13:40** Compared NVFP4 checkpoints; picked `unsloth/Qwen3.8-27B-NVFP4` because it ships the
  MTP head as `model_mtp.safetensors`. Picked image `vllm/vllm-openai:v0.31.0` over the day-old
  v0.32.0 ([decision](decisions/vllm-release-image.md)).
- **13:42** Started image pull (23.9 GB) and model download in parallel. First download ran inside
  a throwaway container and would have left root-owned files; restarted it as the user with `uvx`
  ([lesson](lessons/download-as-user.md)). Download took ~6 min (22 GB).
- **13:45–14:10** A "wait until done" loop never exited: its `pgrep -f` pattern matched its own
  command line ([lesson](lessons/pgrep-self-match.md)).
- **14:19** `serve-qwen.sh` started; ready after 460 s (weights 205 s, profile/compile/graphs 209 s).
  KV cache 68.6 GiB → 1,785,011 tokens. See [runbook](runbooks/qwen3.8-27b-nvfp4.md).
- **14:28** Single request, code, 1024 tokens: 28–29 tok/s, MTP acceptance ~80%.
  8-way random bench (cold): 70 tok/s output.
- **14:43** Re-run for the logs: 26.3 / 29.8 / 30.5 tok/s single; 8-way bench 116 tok/s output,
  acceptance 64% on random tokens. Raw output in [docs/logs](../docs/logs).
