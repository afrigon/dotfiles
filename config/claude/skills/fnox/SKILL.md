---
name: fnox
description: "Reference for fnox, the secrets manager: committing 1Password references in fnox.toml, syncing them into an age-encrypted local cache, shell integration, profiles, running commands under fnox exec, and CI secret injection. Use when adding secrets to a project, creating or editing fnox.toml, setting up fnox on a machine, wiring secrets into mise tasks or GitHub Actions, or debugging secret resolution or shell loading."
---

# fnox

fnox manages secrets through a committed `fnox.toml`. The file holds
references into secret stores (1Password, cloud secret managers) or
values encrypted with age or a cloud KMS — never plaintext. Values
resolve at use time through shell integration, `fnox exec`, or
`fnox get`.

## The workflow

1Password is the source of truth. The committed `fnox.toml` holds only
references into it. Each machine caches the resolved values in a
git-ignored `fnox.local.toml`, encrypted with that machine's personal
age key, so loading is instant and works offline — 1Password is only
contacted when syncing. Shell integration exports the secrets on `cd`
into the project and removes them on the way out.

## Machine setup (once)

fnox, age, and the 1Password CLI install globally through mise; the age
key is generated per machine and never leaves it:

```sh
mise use -g fnox age 1password-cli
age-keygen -o ~/.config/fnox/age.txt
```

The global config `~/.config/fnox/config.toml` declares the personal
cache provider every project syncs through (`fnox provider add sync-age
age --global` scaffolds the entry):

```toml
[providers.sync-age]
type = "age"
recipients = ["age1..."]              # public key printed by age-keygen
key_file = "~/.config/fnox/age.txt"
```

Shell integration goes in the shell profile — for fish:

```fish
fnox activate fish | source
```

Entering a directory whose `fnox.toml` defines secrets then loads them
(`fnox: +2 DATABASE_URL, STRIPE_KEY`); leaving unloads them.
`FNOX_SHELL_OUTPUT` tunes the feedback (`none`, `normal`, `debug`).

The age key can instead live in hardware — a YubiKey, Apple's Secure
Enclave, a TPM — through age plugins; the recipient string then carries
the plugin prefix (`age1yubikey1...`).

## Project setup

Secrets are items in a 1Password vault; `fnox.toml` commits the
provider and the references, never values:

```toml
[providers.op]
type = "1password"
vault = "Engineering"

[secrets]
DATABASE_URL = { provider = "op", value = "Database/url" }
STRIPE_KEY = { provider = "op", value = "Stripe/secret-key" }
```

Reference forms for the 1Password provider:

| `value` | Resolves to |
| --- | --- |
| `"Database"` | The item's `password` field |
| `"Database/url"` | A named field of the item |
| `"op://Engineering/Database/url"` | Full URI; overrides the provider's vault |

Ignore the cache, commit the config:

```sh
echo "fnox.local.toml" >> .gitignore
git add fnox.toml .gitignore
```

Then cache everything locally:

```sh
fnox sync --provider sync-age --local-file
```

This resolves each reference from 1Password, encrypts the value to the
machine's age key, and writes it into `fnox.local.toml` as a `sync`
field beside the reference. Resolution checks the cache first, so the
vault is not contacted again until the next sync.

## Day-to-day

- A value changed in the vault —
  `fnox sync --provider sync-age --local-file --force`. `--dry-run`
  previews; naming secrets or `--filter '^DB_'` narrows the sync.
- A new secret — create the item in 1Password, add the reference to
  `fnox.toml`, commit; every machine re-syncs.
- A new machine — machine setup, clone, sync: its own key encrypts its
  own cache, and nothing else needs sharing.

```sh
fnox get DATABASE_URL         # print one resolved value
fnox list                     # every secret and where it comes from
fnox exec -- <command>        # run with secrets in the environment
fnox set NAME --provider age  # store an encrypted value (prompts)
fnox edit                     # open the config in $EDITOR
fnox remove NAME
```

`fnox set` with an encryption-type provider (age, KMS) writes the
ciphertext into `fnox.toml` itself — safe to commit, and how a secret
that belongs to the repository rather than a vault is stored. CI can
decrypt those from a `FNOX_AGE_KEY` secret without any 1Password
access.

## Profiles

Profiles overlay environment-specific secrets and providers on the
top-level config, which they inherit unless overridden:

```toml
[secrets]
API_URL = { default = "http://localhost:3000" }

[profiles.production.secrets]
API_URL = { provider = "op", value = "Production API/url" }
```

Activate with `--profile`/`-P` or `FNOX_PROFILE`; shell integration
picks up a changed `FNOX_PROFILE` on the next prompt. Several profiles
stack in order (`fnox -P aws -P prod exec -- ./app`), later ones
winning; writes then need `--write-profile`. A profile can also build
on others with `inherits = ["openai", "database-local"]`.
`fnox profiles` lists them.

## Secret entry fields

| Field | Meaning |
| --- | --- |
| `provider` | Which provider resolves this entry |
| `value` | The reference or ciphertext the provider consumes |
| `default` | Fallback when nothing resolves |
| `if_missing` | `error`, `warn`, or `ignore` when unresolvable (also a top-level key) |
| `env` | `true` (always inject), `"exec"` (only under `fnox exec`), `false` |
| `as_file` | Write to a temp file and export the path instead of the value |
| `json_path` | Extract one field from a JSON value, dot notation |
| `line` | Extract the Nth line of a multi-line value |
| `description` | Documentation shown in listings |

## Configuration files

Lowest to highest precedence, later files overriding earlier:

1. `~/.config/fnox/config.toml` — global; providers shared by every
   project, `sync-age` above
2. `fnox.toml` in parent directories, then the current one — merged
   hierarchically, nearest winning
3. `fnox.$FNOX_PROFILE.toml`
4. `fnox.local.toml` — machine-local; the sync cache, git-ignored

## mise projects

fnox comes from mise's global config, not a project's `[tools]` —
machine setup already installed it. Interactive work needs no wiring:
shell integration has the secrets exported before any task runs. A task
that must also work without shell integration — CI, another person's
un-activated shell — wraps its command instead:

```toml
[tasks.dev]
run = "fnox exec -- cargo run"

[tasks.deploy]
run = "fnox exec --profile production -- ./deploy.sh"
```

Declare the need in `fnox.toml`, not in mise's `[env]` — composing
secrets through `[env]` exec templates bypasses the cache and ties the
config to one person's secret store. mise's top-level `redactions`
array still masks named variables in task output.

## CI

CI does not sync — it authenticates straight to the vault. A 1Password
service account (Integrations → Service Accounts, read access to only
the needed vault, token starts with `ops_`) resolves the same committed
references:

```yaml
- run: fnox exec -- mise run test
  env:
    OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
```

A repository whose secrets are age-encrypted in `fnox.toml` needs no
vault access at all: add the CI age identity to the entries'
`recipients` and give the workflow `FNOX_AGE_KEY` as a repository
secret.

## Diagnostics

- `fnox doctor` — setup and environment report
- `fnox check` — validate the config and that every secret resolves
- `fnox config-files` — which config files are loaded, in order
- `fnox list` — every secret, its provider, and its source
- `fnox profiles` — available profiles and the active one
- Shell loading misbehaving — `FNOX_SHELL_OUTPUT=debug`, and
  `fnox deactivate` then re-activate forces a full reload
- Stale value after a vault change — the cache is serving it; re-run
  sync with `--force`
