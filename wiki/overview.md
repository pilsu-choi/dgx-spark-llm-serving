---
type: Overview
title: Overview
description: Hardware, goal, scope and current status of LLM serving on the PGX.
tags: [overview, status]
timestamp: 2026-10-19T14:50:00Z
---

# Overview

## Hardware

Lenovo ThinkStation PGX (DGX Spark OEM): GB10 Grace Blackwell superchip, 20 Arm cores, 128 GB
LPDDR5x unified memory (~119.6 GiB visible to CUDA, ~273 GB/s), 1 TB NVMe for the OS, external 2 TB
USB SSD at `/mnt/ssd` for weights and caches. Setup of the machine itself is in
[dgx-spark-physical-ai](https://github.com/pilsu-choi/dgx-spark-physical-ai).

## Goal

Run useful local LLMs on one Spark as an OpenAI-compatible endpoint on the LAN, record what
works, how fast, and why each setting was chosen.

## Status (2026-10-19)

| Model | Engine | State | Single-request decode |
| --- | --- | --- | --- |
| Qwen3.8-27B NVFP4 + MTP | vLLM 0.31.0 (Docker) | **Serving**, port 8000 | 26–30 tok/s *measured* |

## Constraints

- No passwordless sudo; Docker works because the user is in the `docker` group and the nvidia
  container runtime is installed.
- Weights live on a USB SSD, so cold load of a 22 GB model takes ~3.5 min.
- Unified memory is shared with the CPU side; leave headroom (`--gpu-memory-utilization 0.80`).
