---
type: Lesson
title: pgrep -f matches itself over ssh
description: A remote wait loop using pgrep -f never exited because the pattern appeared in its own command line.
tags: [lesson, shell, ssh]
timestamp: 2026-10-19T14:50:00Z
---

# `pgrep -f` matches itself over ssh

## What happened

```bash
ssh pgx 'until ! pgrep -f "hf download" >/dev/null; do sleep 20; done; ...'
```

`ssh host '<cmd>'` runs `bash -c '<cmd>'`, so the remote shell's own command line contains
`hf download`. `pgrep -f` matched it forever and the loop never ended. The same thing made a later
`pkill -f "<pattern>"` kill the ssh session that ran it (exit 255).

## Fix

Break the literal so the pattern no longer matches itself:

```bash
pgrep -f "hf downloa[d]"
```

Or wait on a PID (`wait`, `tail --pid=`) or on the expected output file instead of a process name.
