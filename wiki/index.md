---
type: Index
title: dgx-spark-llm-serving wiki
description: Entry point: serving LLMs with vLLM on a DGX Spark-class machine.
tags: [index]
timestamp: 2026-10-19T14:50:00Z
---

# dgx-spark-llm-serving wiki

This wiki follows the Open Knowledge Format (OKF v0.1) used in my other projects: plain Markdown
files with YAML frontmatter, one concept per file, ordinary relative links. Each directory has an
`index.md`, and [log.md](log.md) holds the chronological history of the work.

Start with the [overview](overview.md).

| Section | What is there |
| --- | --- |
| [overview.md](overview.md) | Hardware, goal, scope, current status |
| [runbooks/](runbooks/index.md) | Step-by-step: Qwen3.8-27B NVFP4 on vLLM |
| [decisions/](decisions/index.md) | Choices made and why |
| [lessons/](lessons/index.md) | Things that went wrong and what they taught |
| [research/](research/index.md) | What docs and community reports say, checked against the machine |
| [issues/](issues/index.md) | Known gaps and open questions |
| [log.md](log.md) | Chronological work log |

## Conventions

- Every page has `type`, `title`, `description`, `tags` and `timestamp` (UTC, ISO 8601).
- Numbers marked *measured* come from runs on the machine; raw output is in [docs/logs](../docs/logs).
- No secrets, serial numbers, IP addresses or network names are recorded here.
