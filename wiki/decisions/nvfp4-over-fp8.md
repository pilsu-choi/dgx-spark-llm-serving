---
type: Decision
title: NVFP4 over FP8 for Qwen3.8-27B
description: Why the NVFP4 checkpoint (unsloth, with MTP head) was chosen over the official FP8 build.
tags: [decision, quantization, nvfp4, qwen]
timestamp: 2026-10-19T14:50:00Z
---

# NVFP4 over FP8 for Qwen3.8-27B

## Context

The official `Qwen/Qwen3.8-27B-FP8` (blockwise FP8, ~31 GB) fits easily in 128 GB. But a dense
model reads every weight for every token, and Spark's ~273 GB/s memory bandwidth caps decode
speed. Community reports: FP8 ~8 tok/s single-request, ~17 tok/s with MTP.

## Decision

Use NVFP4 (~22 GB weights) with MTP speculative decoding. GB10 (Blackwell, sm_121) runs FP4 in
hardware. Among the NVFP4 builds (`nvidia/`, `Inferact/`, `unsloth/`), `unsloth/Qwen3.8-27B-NVFP4`
was chosen because it ships the MTP head as a separate file, is the most downloaded, and is the
one benchmarked on Spark in the NVIDIA forum.

## Consequences

- *Measured* 26–30 tok/s single request — ~1.7× the FP8 + MTP community figure.
- 4-bit weights can cost some accuracy versus FP8. Not evaluated yet; if quality matters for a
  task, compare against FP8 ([issues](../issues/index.md)).
