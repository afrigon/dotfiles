---
name: try
description: Use a try experiment directory (~/src/tries) instead of /tmp when creating a scratch project, spike, prototype, benchmark, minimal reproduction, or any multi-file experiment, or when cloning a repository just to inspect or test it. Triggers on "experiment", "prototype", "spike", "scratch project", "try it out".
---

# try experiment directories

The user manages experiments with `try` (tobi/try): every experiment lives in one
searchable base directory, browsed with an interactive fuzzy finder sorted by
recency. An experiment created there stays visible and revisitable — unlike
/tmp, which is wiped on reboot and invisible to the user's tooling.

## Layout

- Base directory: `${TRY_PATH:-$HOME/src/tries}`
- One directory per experiment, named `YYYY-MM-DD-slug` with a short
  kebab-case slug, e.g. `2025-08-17-redis-bench`

## When to use

- A scratch or prototype project the user might revisit: a benchmark, a
  minimal reproduction, a spike, test-driving a library or tool
- Cloning a repository only to inspect, build, or test it
- Not for throwaway intermediates of the task at hand (logs, one-off
  scripts, temporary data) — those belong in the session scratchpad

## Rules

- Never run `try` or `try exec` with a query: the fuzzy selector requires a
  TTY and hangs without one
- Never eval scripts emitted by `try exec`: they rename the user's terminal
  panes and workspaces as a side effect
- Instead, create and use directories directly with the commands below —
  they follow try's conventions exactly, so everything appears in the
  user's selector

## Create a new experiment

```sh
dir="${TRY_PATH:-$HOME/src/tries}/$(date +%Y-%m-%d)-<slug>"
mkdir -p "$dir" && cd "$dir"
```

If the directory already exists and holds an unrelated experiment, append
`-2`, `-3`, ...

## Clone a repository to try out

```sh
git clone <url> "${TRY_PATH:-$HOME/src/tries}/$(date +%Y-%m-%d)-<owner>-<repo>"
```

## Experiment on a copy of the current repository

From inside a git repository, create a detached worktree:

```sh
git worktree add --detach "${TRY_PATH:-$HOME/src/tries}/$(date +%Y-%m-%d)-<slug>"
```

## Resume an existing experiment

```sh
ls -t "${TRY_PATH:-$HOME/src/tries}" | head -20
```

`cd` into the matching directory, then `touch` it so it bubbles up in the
user's recency-sorted selector.
