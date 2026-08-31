---
name: repo-standard
description: "Conventions for personal GitHub repositories: naming, README, LICENSE, description, topics, .gitignore, mise version pinning, task runner choice, and repository settings. Use when creating a repository or scaffolding a new project, when auditing or standardizing an existing repository, and when deciding what to name a repository or which task runner it should use."
---

# Repository standard

Two tiers. Decide which applies before anything else.

**Code tier** — the repository contains software that is built, run, or imported. Every rule below applies.

**Data tier** — the repository stores files with no build: notes, configuration dumps, schematics, save states, assets consumed elsewhere. Only Naming, Description, Topics, Gitignore, and Settings apply. Do not add a LICENSE, a `mise.toml`, a task runner, or a structured README to a data-tier repository.

A repository that exists only to hold credentials or signing material is data tier and stays private.

## Naming

Lowercase kebab-case is the default: `image-proxy`, `deploy-tools`, `chart-react`.

Three things override that default, in order:

1. **The language standard wins.** Swift applications and packages are PascalCase, because that is the Swift convention: `NetworkKit`, `ImageCache`.
2. **An external ecosystem convention wins.** A plugin for another tool takes that tool's prefix so it sorts beside its siblings, not beside the rest of the account: a tree-sitter grammar is `tree-sitter-<language>` so it lands next to `tree-sitter-go`, a Zed extension is `zed-<language>`, a Homebridge plugin is `homebridge-<device>`.
3. **Otherwise, group by prefix.** Related repositories share a leading noun so they cluster when sorted: `chart-react` and `chart-swift`, `player-api` and `player-ios`. Never encode the relationship as a suffix — `aws-bootstrap` scatters what `bootstrap-aws` groups.

A trailing platform names a variant within a family: `tools-macos` alongside `tools-linux`, `bootstrap-macos` alongside `bootstrap-aws`.

Do not put the artifact type in the name. A repository is not `-cli`, `-lib`, or `-app`; what it produces belongs in the description.

## Description

Required. One line, sentence case, no trailing period. Say what the thing is, not what it is built with.

```
Convert CSV exports into a queryable SQLite database
```

## Topics

Required, three to eight, lowercase kebab-case. Cover the language, the domain, and any ecosystem a person would search by.

```
cli  csv  sqlite  data-import
```

## README

Required on the code tier. Open with the repository name as an `h1`, then a paragraph saying what it is and why it exists — not a feature list.

After that, only sections the repository actually needs:

- **Install** or **Quick start** — how to get a working copy, exact commands
- **Usage** — the common cases, as commands with real arguments
- **Configuration** — every key, if the thing reads a config file
- **Development** — how to build, test, and lint, if that differs from usage

Write commands as copy-pasteable blocks. Do not add badges that point at a service the repository does not use; a dead badge is worse than none. Do not write a Contributing or Code of Conduct section for a personal repository.

## License

MIT on every code-tier repository, public or private, in a root file named exactly `LICENSE` — not `LICENSE.txt`, not `LICENSE-MIT`. Copy `templates/LICENSE`, set `{{YEAR}}` to the year of first commit, and set `{{HOLDER}}` to the repository owner — the name from `git config user.name`.

Data-tier repositories get no license. Neither do forks — a fork keeps its upstream license untouched.

## Gitignore

Required. Always ignore `.DS_Store`, `.claude`, and `.env` files — keeping `.env.example` and `.env.op`, which hold shape and references, never values. Add the artifacts of every language present, not just the primary one. A repository with a `mise.toml` also ignores `mise.local.toml`.

`templates/gitignore/` holds a base, one file per language, and a `mise` file. Concatenate the base with each language that applies, plus `mise` wherever a `mise.toml` exists. Verify the entries match reality: a pattern without a leading dot, like `DS_Store`, silently matches nothing.

## Version pinning

Every code-tier repository has a `mise.toml` pinning its toolchain through a committed `mise.lock`:

```toml
[settings]
lockfile = true

[tools]
node = "24"
"github:{owner}/{tool}" = "latest"
```

Specs stay loose. External tools name the major version, so an upgrade never silently crosses one; tools owned by the same account track `latest`, because their releases are yours to control. The lock records the exact resolved version, download URL, and checksum per platform — that is what makes two machines resolve identically, so `mise.lock` is committed, never ignored. Upgrading is deliberate: `mise lock --bump` re-resolves the specs, and the change lands as a commit.

The `lockfile` setting lives in the repository's `mise.toml`, not in global config — CI reads only the repository's file.

## Toolchain

One toolchain per language:

| Language | Toolchain |
| --- | --- |
| Python | `uv` |
| Rust | `cargo` |
| JavaScript / TypeScript | `aube` |
| Swift | Swift Package Manager |
| C / C++ | `make` |

Any language not in the table uses whatever ships with it — `go` for Go, `terraform` for HCL. Where a language has no meaningful toolchain, as with shell scripts, the rule does not apply.

Nothing else scaffolds a project in a listed language. A Python repository does not use `pip` and a bare `venv`; a Swift package does not carry a hand-rolled Xcode project as its build entry point.

Dependencies are never installed globally. Every toolchain that supports project-local isolation must use it — `uv` resolves into `.venv`, `aube` into the project's `node_modules`, `cargo` into `target`. A setup step that writes into the user's home or a system path is wrong; only the toolchains themselves are installed globally, through mise.

## Tasks

Tasks live in `mise.toml`, under `[tasks]`. mise is already required for version pinning, so tasks sit beside the tools that run them and there is no second runner to install.

A repository that builds defines `build` and `run` at minimum. Add `test`, `lint`, and `format` where they exist. Tasks call the language toolchain — mise orchestrates, it does not replace `cargo` or `uv`.

```toml
[tasks.build]
description = "Build in release mode"
run = "cargo build --release"

[tasks.test]
depends = ["build"]
run = "cargo test"
```

A task that takes arguments declares them, so `mise run` can check and document them:

```toml
[tasks.deploy]
usage = '''
arg "<environment>" help="where to deploy"
flag "--dry-run" help="print the plan without applying"
'''
run = 'deploy --target "$usage_environment"'
```

A task that outgrows a `run` string becomes an executable script in `.mise/tasks/`, where it is an ordinary shell script rather than a string inside TOML.

Secrets reach a task through its own `env`, never inline in the command:

```toml
[tasks.serve]
env = { API_TOKEN = "{{ exec(command='op read op://Personal/…/api-token') }}" }
run = "./serve --verbose"
```

An application built through Xcode is the exception to the `build` and `run` minimum: Xcode owns building and running it. Such a repository still defines tasks for everything around that — lint, format, test, code generation — so they are invoked the same way as in every other repository.

C and C++ repositories keep a Makefile, because make genuinely drives compilation there: object files, link steps, header dependencies. Their tasks call `make`.

A Makefile in any other language is a task runner wearing the wrong hat. Port it to `[tasks]`.

## Containers

A `Dockerfile` belongs wherever an image is the artifact: a service that gets deployed, or a reproducible build environment such as a cross-compilation toolchain.

A `docker-compose.yml` is narrower. Add one only when running the project means running more than one thing — a service plus the database, cache, or queue it depends on. Then compose is the canonical way to start the stack, and `docker compose up` must give a working system. A Dockerfile with nothing to compose alongside it does not get a compose file.

A library, a CLI, a static site, or anything that runs only on a developer's machine needs neither.

## Continuous integration

Every repository created from here on runs CI on pull requests, wherever the language supports it: build, then test and lint if they exist. The workflow calls the same mise tasks a person would, so CI and local runs cannot drift.

Repositories predating this standard are exempt. Do not add CI to an existing repository as part of a standardization pass — only when it is being worked on for another reason.

CI matters more once versions are locked: a lock that has gone stale fails in CI rather than on a machine months later.

## Secrets

No secret in the tree, in any tier, public or private. Reference secrets through 1Password and commit the reference, not the value:

```
DATABASE_PASSWORD="op://Infrastructure/Postgres/password"
```

Wherever a `.env.example` documents the shape, a `.env.op` sits beside it holding the same keys as `op://` references. The example shows what is needed; the `.env.op` resolves it.

A secret that reached a commit is compromised — rotate it. Deleting the file does not help, because the history keeps it.

## Repository settings

Every feature is off unless it is carrying something. An enabled empty feature is a dead tab.

| Feature | Rule |
| --- | --- |
| Default branch | `main`. Rename `master`, do not branch from it and leave it behind. |
| Wiki | Off, unless the wiki has pages. |
| Projects | Off, unless a project is linked to the repository. |
| Releases | Off, unless a release is published. |
| Packages | Off, unless a package is published. |
| Deployments | Off, unless a deployment has run. |
| Issues | On. |
| Delete head branches on merge | On. A merged branch has nothing left to say. |
| Suggest updating pull request branches | On. Offers the update rather than leaving a stale branch to be merged blind. |

These are settable through the API:

```sh
gh api -X PATCH repos/{owner}/{repo} \
  -F has_wiki=false -F has_projects=false \
  -F delete_branch_on_merge=true -F allow_update_branch=true
```

Releases, Packages and Deployments are home-page visibility toggles with no API. Set them by hand under the repository's About panel.

Rename a default branch through the API, which retargets open pull requests and leaves no `master` behind:

```sh
gh api -X POST repos/{owner}/{repo}/branches/master/rename -f new_name=main
```

Every repository has an active branch ruleset named `protect-default-branch` blocking deletion and force pushes on the default branch. Create it through the API:

```sh
gh api -X POST repos/{owner}/{repo}/rulesets --input - <<'EOF'
{
  "name": "protect-default-branch",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [{ "type": "deletion" }, { "type": "non_fast_forward" }]
}
EOF
```

Archiving makes a repository read-only. Where a repository is going to be archived, complete every settings and content change before archiving it.

Forks are exempt from every content rule. Do not add a license, a `mise.toml`, or a standard README to a tree that belongs upstream; give a fork settings hygiene only.
