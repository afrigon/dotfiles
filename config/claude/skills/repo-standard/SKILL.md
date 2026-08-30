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

Required. Always ignore `.DS_Store` and `.claude`. Add the artifacts of every language present, not just the primary one.

`templates/gitignore/` holds a base plus one file per language. Concatenate the base with each language that applies. Verify the entries match reality: a pattern without a leading dot, like `DS_Store`, silently matches nothing.

## Version pinning

Every code-tier repository has a `mise.toml` pinning its toolchain.

External tools take an exact version, so two machines resolve identically:

```toml
[tools]
rust = "1.90.0"
node = "24.4.1"
```

Tools owned by the same account track `latest`, because their releases are yours to control:

```toml
[tools]
"github:{owner}/{tool}" = "latest"
```

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

## Task runner

Any repository that builds has a `justfile` with `build` and `run` at minimum. Add `test`, `lint`, and `format` where they exist. Recipes call the language toolchain — `just` orchestrates, it does not replace `cargo` or `uv`.

C and C++ repositories keep a Makefile, because make genuinely drives compilation there: object files, link steps, header dependencies. They still get a `justfile` if they need tasks beyond building, and its recipes call `make`.

A Makefile in any other language is a task runner wearing the wrong hat. Port it to a `justfile`.

`mise [tasks]` covers the narrow case where a task needs the mise-managed environment or a secret that must not reach a `justfile`:

```toml
[tasks.serve]
env = { API_TOKEN = "{{ exec(command='op read op://Personal/…/api-token') }}" }
run = "./serve --verbose"
```

## Containers

A project that is meant to be hosted — an API, a service, anything that runs somewhere other than a developer's machine — ships a `Dockerfile` and a `docker-compose.yml`.

The Dockerfile builds the deployable image. The compose file is the canonical way to run the whole thing: the service plus every backing store it needs, so a single `docker compose up` gives a working stack. Publish the compose file alongside whatever configuration it reads, and keep it working — it is the self-hosting instructions in executable form.

A library, a CLI, or anything that runs only on a developer's machine does not need either.

## Continuous integration

Every repository created from here on runs CI on pull requests, wherever the language supports it: build, then test and lint if they exist. The workflow calls the same justfile recipes a person would, so CI and local runs cannot drift.

Repositories predating this standard are exempt. Do not add CI to an existing repository as part of a standardization pass — only when it is being worked on for another reason.

CI matters more once versions are pinned exactly: a pin that has gone stale fails in CI rather than on a machine months later.

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

Wiki and Projects are settable through the API:

```sh
gh api -X PATCH repos/{owner}/{repo} -F has_wiki=false -F has_projects=false
```

Releases, Packages and Deployments are home-page visibility toggles with no API. Set them by hand under the repository's About panel.

Rename a default branch through the API, which retargets open pull requests and leaves no `master` behind:

```sh
gh api -X POST repos/{owner}/{repo}/branches/master/rename -f new_name=main
```

Archiving makes a repository read-only. Where a repository is going to be archived, complete every settings and content change before archiving it.

Forks are exempt from every content rule. Do not add a license, a `mise.toml`, or a standard README to a tree that belongs upstream; give a fork settings hygiene only.
