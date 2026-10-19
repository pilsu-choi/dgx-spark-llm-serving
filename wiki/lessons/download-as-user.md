---
type: Lesson
title: Download weights as the user
description: Running hf download inside a throwaway container writes root-owned files to the bind mount.
tags: [lesson, huggingface, docker, permissions]
timestamp: 2026-10-19T14:50:00Z
---

# Download weights as the user

## What happened

The first download ran `hf download` inside `python:3.12-slim` with `/mnt/ssd/models` bind-mounted.
Containers run as root by default, so every file it wrote would have been owned by root, and the
user (no passwordless sudo) could not later delete or move them.

## Fix

Download on the host as the user, with no install needed:

```bash
uvx --from 'huggingface_hub[hf_xet]' hf download <repo> --local-dir /mnt/ssd/models/<name>
```

Mount the weights read-only into the serving container (`-v /mnt/ssd/models:/models:ro`).

## Takeaway

Anything a container writes to a host path should either run with `--user $(id -u):$(id -g)` or
happen on the host.
