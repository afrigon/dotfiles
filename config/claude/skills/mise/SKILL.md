---
name: mise
description: "Reference for mise: pinning tools in mise.toml, defining and running TOML tasks, per-project environment variables, templates, mise.lock, and running mise in CI. Use when creating or editing mise.toml or mise task files, wiring mise into a GitHub Actions workflow, or debugging tool resolution, task execution, or environment problems."
---

# mise

mise does three jobs from one `mise.toml`: pin tool versions per project,
run tasks, and set environment variables scoped to a directory.

## Configuration files

`mise.toml` at the project root is the canonical file. Two variants sit
beside it:

- `mise.local.toml` — personal overrides; belongs in `.gitignore`. Highest
  precedence.
- `mise.{env}.toml` — loaded only when `MISE_ENV={env}` is set, e.g.
  `mise.production.toml`.

mise searches upward from the current directory to the filesystem root and
merges every config it finds, nearest file winning. `[tools]`, `[env]`, and
`[settings]` merge key-by-key; each task under `[tasks]` replaces a
same-named task from a farther file wholesale. The global config at
`~/.config/mise/config.toml` sits at the bottom of the stack.

mise refuses to load an unseen config until it is trusted — `mise trust`
approves the current one. `mise config` lists every file in the active
stack, which is the first thing to check when a value is not what you
expect.

Editors validate and complete `mise.toml` against the schema at
`https://mise.jdx.dev/schema/mise.json`.

## Tools

```toml
[tools]
node = "24.4.1"          # exact pin
python = "3.12"          # fuzzy: latest 3.12.x at install time
rust = "latest"
```

Bare names resolve through the mise registry (`mise registry` lists it).
Anything else takes a backend prefix:

| Syntax | Installs from |
| --- | --- |
| `"github:owner/repo"` | GitHub release binaries |
| `"ubi:owner/repo"` | GitHub releases via the ubi installer |
| `"cargo:crate"` | crates.io, built with cargo |
| `"npm:package"` | npm |
| `"pipx:package"` | PyPI, isolated like pipx |
| `"go:module/path"` | `go install` |
| `"aqua:owner/repo"` | the aqua registry (checksummed) |

Prefer editing `[tools]` by hand in a project you control; `mise use
tool@version` does the same and also installs. Everyday commands:

```sh
mise install          # install everything the config asks for
mise upgrade          # bump installed versions within their constraints
mise outdated         # show pins that have fallen behind
mise ls               # what is installed and which config requested it
mise which <tool>     # path to the real binary
mise x -- <cmd>       # run one command with the project's tools on PATH
```

mise also honors idiomatic version files (`.nvmrc`, `.python-version`,
`rust-toolchain.toml`, ...) when enabled per tool via the
`idiomatic_version_file_enable_tools` setting; a `mise.toml` in the same
directory takes precedence.

## Tasks

Tasks live under `[tasks]` in `mise.toml`. Prefer TOML tasks; reach for a
file task only when a script outgrows a `run` string.

```toml
[tasks.build]
description = "Build in release mode"
run = "cargo build --release"

[tasks.test]
depends = ["build"]
run = "cargo test"
```

The one-liner form works for trivial cases: `lint = "cargo clippy"`
directly under `[tasks]`.

Every binary a task invokes comes from `[tools]` — if a task calls
`shellcheck`, `[tools]` pins `shellcheck`. A task that reaches for a
system-installed binary works on one machine and fails on the next, and
fails in CI where only mise-managed tools exist. The exceptions are the
POSIX baseline (`sh`, `cp`, `grep`, ...) and platform-owned commands a
tool cannot be pinned for (`docker`, `open`, `systemctl`). A tool needed
by exactly one task can ride on that task's `tools` key instead of the
top-level table.

### run

A string, or an array of strings executed sequentially — a failing entry
stops the rest. With `sh`/`bash`/`zsh` the script runs under `set -e`.
Extra CLI arguments (`mise run build --release`) are appended to a string
`run`, and to only the **last** entry of an array `run`.

A multiline `run` starting with a shebang executes as a script file, so
`$1` and `$@` work, and any interpreter goes:

```toml
[tasks.report]
run = """
#!/usr/bin/env python
print("hello")
"""
```

Use `#!/usr/bin/env -S` when the interpreter needs flags. `run_windows`
provides a Windows alternative to `run`.

### Dependencies

```toml
[tasks.ci]
depends = ["lint", "test"]                # run first, in parallel
depends_post = ["cleanup"]                # run after, even on failure
wait_for = ["migrate"]                    # order-only: wait if scheduled,
                                          # but do not pull it in
```

A dependency referenced by several tasks runs once. Entries can carry
arguments and environment: `{ task = "build", args = ["--release"] }`.

### Arguments and flags

Declare them with `usage` so `mise run` validates and documents them; each
becomes a `usage_`-prefixed environment variable:

```toml
[tasks.deploy]
usage = '''
arg "<environment>" help="Where to deploy"
flag "--dry-run" help="Print the plan without applying"
flag "--region <region>" help="Target region" default="us-east-1"
'''
run = 'deploy --target "$usage_environment" --region "$usage_region"'
```

The Tera `{{arg()}}`/`{{option()}}`/`{{flag()}}` template functions are
deprecated in favor of `usage`.

### The full key list

| Key | Meaning |
| --- | --- |
| `description` | Shown by `mise tasks` and completions |
| `alias` | Alternate name(s): `alias = "b"` |
| `depends` / `depends_post` / `wait_for` | See above |
| `env` | Variables for this task only, not passed to `depends` |
| `dir` | Working directory; default is the config root, `"{{cwd}}"` runs where invoked |
| `sources` / `outputs` | Globs for freshness: skip when outputs are newer than sources; `!` negates; `--force` reruns |
| `tools` | Extra tool pins just for this task: `tools.rust = "1.90.0"` |
| `shell` | Interpreter for a string `run`, e.g. `"bash -c"` |
| `timeout` | Kill the task after a duration: `"5m"` |
| `confirm` | Prompt before running: `confirm = "Release?"` |
| `hide` | Omit from listings |
| `quiet` / `silent` | Suppress mise's chatter / all task output |
| `raw` | Attach stdin/stdout directly; disables parallelism for the task |
| `file` | Delegate to a script file instead of `run` |

Reusable values go in a top-level `[vars]` table and interpolate as
`{{vars.name}}`; unlike `[env]` they are not exported to the process.

### Secrets

Never inline a secret in a command, and never compose one through
`[env]` — an `exec` template that queries a secret store runs on every
environment composition and hard-wires one person's tooling into the
tracked config. Secrets belong to fnox: the project's committed
`fnox.toml` declares which secrets exist and which store resolves them,
fnox's shell integration exports them for interactive work, and a task
that must also run without it — CI, an un-activated shell — wraps its
command:

```toml
redactions = ["API_TOKEN"]

[tasks.serve]
run = "fnox exec -- ./serve --verbose"
```

The top-level `redactions` array masks the named variables in task
output.

### File tasks

A script that outgrows TOML becomes an executable file in `.mise/tasks/`
(`mise-tasks/` and `mise/tasks/` also work). The filename is the task
name; it must be `chmod +x`. Metadata rides in comments:

```bash
#!/usr/bin/env bash
#MISE description="Rebuild the site"
#MISE depends=["clean"]
#MISE sources=["content/**/*.md"]
#USAGE flag "--drafts" help="Include drafts"

build --drafts="$usage_drafts"
```

## Running tasks

```sh
mise run build                  # or: mise r build
mise run test -- --nocapture    # args after the task name go to the task
mise run build ::: test         # several tasks, in parallel
mise run 'test:*'               # wildcard over : separated groups
mise tasks                      # list; --hidden includes hide=true
mise tasks deps                 # dependency graph
mise watch build                # rerun on source change (via watchexec)
```

mise's own flags go **before** the task name: `mise run --jobs 8 build`.
Tasks run up to four in parallel by default (`--jobs`, `MISE_JOBS`);
parallel output is line-prefixed with the task name, switching to
interleaved at `--jobs 1` (`--output prefix|interleave|keep-order`).
`mise run` with no task runs the task named `default` if one exists.

## Environment

```toml
[env]
NODE_ENV = "development"
LIB_DIR = "{{config_root}}/lib"
DATABASE_URL = { required = true }        # error if nothing provides it
RUST_LOG = { default = "info" }           # keep an existing value
OLD_VAR = false                           # unset it
_.path = ["{{config_root}}/bin"]          # prepend to PATH
_.file = ".env"                           # load a dotenv/JSON/YAML/TOML file
_.source = "./scripts/env.sh"             # capture exports from a script
```

`required = true` pairs with `mise.local.toml`: the tracked config declares
the need, the git-ignored one supplies the value. Values referencing tool
paths need `tools = true` (`{ value = "...", tools = true }`) so they
resolve after tools do. `mise env` prints the composed environment
(`--json`, `--dotenv`); `mise set`/`mise unset` edit `[env]` from the CLI.

## Templates

Most `mise.toml` values accept Tera templates in `{{ }}` — the file itself
must still be valid TOML. The essentials:

- Variables: `env.VAR`, `vars.name`, `config_root`, `cwd`
- Functions: `exec(command='...')` (with optional `cache_key`/
  `cache_duration`), `os()`, `arch()`, `num_cpus()`,
  `get_env(name='X', default='y')`
- Filters: `{{ path | quote }}` for shell-safe quoting, `basename`,
  `dirname`, `join_path`

## Lockfile

```toml
[settings]
lockfile = true
```

With that set, mise maintains a committed `mise.lock` recording the exact
resolved version, download URL, and checksum per platform — fuzzy specs
like `"3.12"` become reproducible, and CI installs verify checksums.
`mise lock --bump` re-resolves fuzzy specs to their latest matches. Full
checksum support covers the `github`, `gitlab`, `aqua`, and `http`
backends.

## GitHub Actions

`jdx/mise-action` installs mise, runs `mise install`, caches tool installs
keyed on the config, and puts everything on PATH:

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
      - uses: jdx/mise-action@c2a87611a18de5b3828c5652fe268e992400cb5c # v4.3.0
      - run: mise run build
      - run: mise run test
```

Actions are pinned to the commit SHA of their latest release, never to a
tag, with the readable version in a trailing comment. A tag is a moving
pointer: whoever owns the repository can repoint it at different code
after it was reviewed, and the workflow picks that up silently. A SHA
cannot move. Resolve one with:

```sh
gh api repos/{owner}/{repo}/git/ref/tags/{tag} --jq .object.sha
```

An annotated tag returns `.object.type == "tag"`; dereference it with
`gh api repos/{owner}/{repo}/git/tags/{sha} --jq .object.sha`.

Workflow steps call the same mise tasks a person runs locally, so CI and
local runs cannot drift. Action inputs worth knowing: `version` pins the
mise version itself, `install: false` skips `mise install`, `cache: false`
disables caching, and `mise_toml` supplies an inline config when the job
should not read the repository's.

On any CI without a dedicated integration, the pattern is:

```sh
curl https://mise.run | sh
mise install
mise x -- <command>       # or: mise run <task>
```

## Diagnostics

- `mise doctor` — environment, activation state, and problem report
- `mise config` — which config files are loaded, in order
- `mise ls` — installed tools and which config requested each
- `mise which <tool>` — the real binary a shim points at
- `mise env` — the composed environment as mise sees it
- `mise tasks deps` — why a task is running or blocked
- "Config file is not trusted" — run `mise trust`
- A task unexpectedly skipped — its `sources`/`outputs` say it is fresh;
  rerun with `mise run --force <task>`
