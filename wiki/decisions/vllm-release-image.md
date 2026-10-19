---
type: Decision
title: Pinned vLLM release image
description: Why vllm/vllm-openai:v0.31.0 in Docker instead of a pip install or a nightly.
tags: [decision, vllm, docker]
timestamp: 2026-10-19T14:50:00Z
---

# Pinned vLLM release image

## Context

vLLM can be pip-installed into a venv or run from Docker. On aarch64 + CUDA 13 the pip route means
matching torch/flashinfer wheels by hand. Docker Hub `vllm/vllm-openai` publishes multi-arch
(amd64 + arm64) release tags and nightlies.

## Decision

Docker, `vllm/vllm-openai:v0.31.0` (released 2026-10-04). v0.32.0 had been out one day; the
nightly tags move daily. The tag is pinned in [serve-qwen.sh](../../scripts/serve-qwen.sh).

## Consequences

- Worked first time on GB10 with no patches or env hacks beyond the memory-profiler flag.
- The image is 23.9 GB on the internal disk.
- Upgrading is a one-line tag change; re-measure with [tps.py](../../scripts/tps.py) after.
