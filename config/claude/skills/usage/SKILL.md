---
name: usage
description: "Reference for usage, the CLI definition toolkit: declaring a Rust CLI with usage-rs derives, the KDL usage spec, the __usage_spec__ endpoint and a committed spec file, the usage CLI for lint, diff, completions, markdown, and manpages, and shebang scripts with #USAGE comments. Use when adding or changing commands, flags, or args in a CLI built on usage-rs, migrating a CLI from clap, writing or editing a .usage.kdl file, generating completions or docs from a spec, or debugging how a command line parses."
---

# usage

usage describes a command-line interface once — commands, flags, args,
env vars — and derives everything else from that description: argument
parsing, `--help`, shell completions, Markdown docs, man pages, SDKs, and
an interface diff between releases. The description is a *usage spec*, a
KDL document. Documentation lives at https://usage.jdx.dev.

Two directions exist, and which one applies depends on the language:

- **Rust (`usage-rs`)**: the Rust declaration is the source. Derive macros
  compile structs into static parse tables at build time and emit the KDL
  spec from the same metadata. No KDL is parsed when the binary runs, and
  nothing loads a KDL file to generate Rust.
- **Everything else**: the KDL file is the source. Go reads it through
  `usage generate go`, shell scripts carry it in `#USAGE` comments, and
  the `usage` CLI consumes it for every generated artifact.

The `usage` CLI is a separate binary from the library. A Rust binary
parses on its own with no runtime dependency; the CLI is needed only for
the artifacts (docs, manpages, lint, diff) and for completion scripts of
non-Rust programs.

## Setup

```toml
[dependencies]
usage = { package = "usage-rs", version = "6" }

[dev-dependencies]
usage = { package = "usage-rs", version = "6", features = ["test"] }
```

The crate is published as `usage-rs` and renamed to `usage` so code says
`use usage::Cli;`. Depend on the facade only, never on `usage-derive` or
`usage-argv` directly.

| Feature | Default | Gates |
| --- | --- | --- |
| `spec` | yes | Spec metadata, `to_kdl()`, and the derives themselves |
| `help` | yes | `-h` / `--help` rendering |
| `diagnostics` | yes | clap-shaped error messages; without it failures render as `Debug` |
| `completions` | no | Completion scripts and the runtime completion protocol; required by `#[usage(completion)]` |
| `validation` | no | Portable `validate = "…"` expressions (adds `expr-lang`) |
| `test` | no | `usage::test` assertions; dev-dependency only |
| `config` | no | The `Config` derive and `usage::config` resolver |
| `response-files` | no | `@file` argv expansion as `usage::response` |

The CLI installs through mise (`usage = "<version>"` under `[tools]`, or
`mise use -g usage`), cargo (`cargo install usage-cli`), Homebrew
(`brew install usage`), or pacman (`pacman -S usage`). The `usage-rs`
version that emits a spec and the `usage` CLI that reads it should track
the same major version.

## Declaring a CLI

```rust
use usage::{Args, Cli, Run, Subcommands};

/// A tool that does things
#[derive(Cli)]
#[usage(bin = "ex", version, unknown_flags = "error")]
struct Ex {
    /// Say more
    #[usage(short = 'v', long, global)]
    verbose: bool,

    #[usage(subcommand)]
    command: Commands,
}

#[derive(Subcommands)]
#[usage(run)]
enum Commands {
    Install(Install),
    /// Show who pays for this
    Sponsors,
}

/// Install a tool
#[derive(Args)]
struct Install {
    /// Overwrite an existing install
    #[usage(short = 'f', long)]
    force: bool,
    /// What to install
    tools: Vec<String>,
}

impl Run for Install {
    type Output = ();
    fn run(self) { /* … */ }
}

impl Run for CommandsSponsors {
    type Output = ();
    fn run(self) { /* … */ }
}

fn main() {
    Ex::parse().command.run()
}
```

Every helper attribute is `#[usage(...)]`, on structs, enums, variants,
and fields alike. Doc comments are help text: the first paragraph is the
short help shown by `-h`, the whole comment the long help shown by
`--help`. `help = "…"` and `long_help = "…"` do the same as attributes.

Two defaults differ from clap and usually want overriding on the root:

- `unknown_flags = "error"` — by default an unrecognized `--flag` becomes
  a positional value instead of an error, which suits wrapper CLIs and
  nothing else.
- `args_override_self = false` — by default a repeated scalar flag is
  last-one-wins instead of a duplicate-flag error.

### Root attributes

| Attribute | Meaning |
| --- | --- |
| `bin = "…"` | Binary name in help and spec; may be an expression, paired with `bin_spec = "literal"` for the KDL |
| `name = "…"` | Friendly display name (`name_spec` for the portable literal) |
| `version` / `version = "…"` | Enables `-V` / `--version`; bare form uses `CARGO_PKG_VERSION`; `long_version` for a richer `--version` |
| `about`, `long_about`, `before_help`, `after_help` (+ `_long_` forms) | Page text; doc comments cover `about` / `long_about` |
| `author`, `license`, `repository` | Package metadata, take expressions such as `env!("CARGO_PKG_REPOSITORY")` |
| `unknown_flags = "error"` | Reject unrecognized flags (default `"value"`) |
| `args_override_self = false` | Refuse a repeated scalar flag (default: last wins) |
| `default_subcommand = "run"` | Command assumed when argv names none; a nonexistent name fails the build |
| `multicall` | argv[0]'s basename selects a subcommand (busybox style) |
| `view("bin", root = "cmd", globals)` | Expose one command as its own executable; `global = "--flag"` instead of `globals` to carry only named globals |
| `completion` | Generate completion support (needs the `completions` feature) |
| `spec_endpoint = false` | Remove the `__usage_spec__` endpoint (saves ~65 KB); `to_kdl()` stays |
| `spec_extra = "path.kdl"` | Append a file's raw KDL to the emitted spec, read at compile time |
| `min_usage_version = "…"` | Written first in the KDL as the minimum reader version |
| `group("name")`, `group("name", required)`, `group("name", required, multiple)` | Flag group: at most one, exactly one, at least one |
| `help_template = "…"` | Page layout with `{{about}}`, `{{usage}}`, `{{commands}}`, `{{args}}`, `{{flags}}`, `{{after_help}}` (plus `grouped_`/`ungrouped_` splits) |
| `validate_with = function` | `fn(&Self) -> Result<(), ValidationError>` run on every parse path |
| `try_into = Type` | Generates `parse_into*` entry points through `TryFrom<Self, Error = ValidationError>` |
| `example = "…"` / `example("…", header = "…", help = "…")` | Worked invocations, repeatable |
| `rename_all = "…"`, `rename_all_env = "…"` | Case for inferred names; explicit `long`, `name`, `env = "X"` still win |
| `arg_required_else_help`, `disable_help_flag`, `disable_help_subcommand`, `disable_version_flag`, `subcommand_negates_reqs`, `args_conflicts_with_subcommands`, `subcommand_precedence_over_arg`, `allow_missing_positional`, `dont_delimit_trailing_values`, `no_binary_name`, `term_width`, `max_term_width`, `next_line_help`, `flatten_help`, `subcommand_help_heading`, `subcommand_value_name` | clap names, clap meanings |

`Args` structs accept `alias = "…"`, `alias_hidden = "…"`, `effect =
"read" | "write" | "destructive"`, `mount = "cmd"`, `restart_token = ":::"`,
`example`, `output(…)`, and `exit_code(…)`. Tuple structs are not
inferred: `struct Wrapper(Common);` is a compile error, use a named field
with `flatten`.

### Fields

A field is a flag when it carries `long` or `short`, and a positional
otherwise (or explicitly with `arg`). The type decides cardinality and
requiredness:

| Type | Meaning |
| --- | --- |
| `T` | One value, required |
| `Option<T>` | One value or nothing |
| `Vec<T>` | Several values; empty when none given; a `Vec` flag is repeatable |
| `Option<Vec<T>>` | Several values; `None` when never given |
| `bool` | A switch |
| `u8`…`usize` with `count` | Occurrence count (`-vvv` → 3) |
| `Option<Option<T>>` | Absent / bare `--flag` / `--flag=v` are three distinct states |

Values go through `FromStr`, whose error type must implement `Display`.
A `default` or `env` makes a field optional in the grammar. A required
`Vec` is the one explicit case: `#[usage(arg, required)]`.

| Attribute | Meaning |
| --- | --- |
| `long` / `long = "name"`, `short` / `short = 'x'` | Flag spellings; bare forms infer from the field name |
| `name = "…"` | Name in help and spec |
| `arg` | Force positional |
| `negate = "--no-x"` | Negation spelling that sets a `bool` false |
| `count` | Count occurrences into an integer field |
| `global` | Accepted on every subcommand beneath, once per level |
| `skip` | Not an argument, filled from `Default`; combining with anything else is a compile error |
| `subcommand` | The field holds the subcommand enum; `Option<E>` optional, bare `E` required |
| `flatten` | Splice another `Args` struct's flags and args; `next_help_heading = "…"` heads them |
| `env = "X"` / `env`, `env_fallback("A", "B")`, `deprecated_env("OLD")` | Environment fallback chain, in declaration order |
| `default = "…"` | Fallback value (repeatable for `Vec`) |
| `default_fn = function`, `default_note = "…"` | Computed default; spec marks the field optional and carries the note as prose |
| `default_missing = "…"` | Value when the flag is given bare (`--color` vs `--color=never`) |
| `default_if("--json", "true")` / `default_if("--output", "json", "pretty")` | Conditional default when another flag is present / equals a value |
| `choices("a", "b")`, `choices_strict = false` | Fixed value set; non-strict keeps suggestions but accepts anything |
| `value_enum` | Take choices from a `#[derive(ValueEnum)]` type |
| `var`, `variadic`, `var_min = n`, `var_max = n`, `num_args = n` / `a..=b` | Repeatable flag (one value per occurrence) vs greedy occurrence (`--include a b c`); bounds |
| `delimiter = ','` | Split one word into several values; field must be `Vec` |
| `value_terminator = ";"` | Ends a variadic run without storing the token |
| `require_equals` | Accept `--flag=v` only |
| `allow_hyphen_values`, `allow_negative_numbers` | Let a detached value look like a flag / a negative number |
| `double_dash = "…"` | One of `optional`, `required`, `preserve`, `automatic`: how `--` interacts with this positional; `trailing_var_arg` lowers to `automatic` |
| `conflicts(…)`, `requires(…)`, `overrides(…)`, `required_if(…)`, `required_if_eq(…)`, `required_unless(…)`, `required_unless_all(…)`, `requires_if(…)`, `exclusive` | Relationships, selectors spelled `"--flag"`, `"-s"`, or a positional name; a nonexistent selector is a compile error |
| `group = "name"` | Membership in a group declared on the struct |
| `validate = "int(value) >= 1"`, `validate_error = "…"` | Portable expression rule (feature `validation`) |
| `value_name = "…"`, `value_names = ["A", "B"]`, `help_heading = "…"`, `display_order = n`, `hide`, `note = "…"`, `warning = "…"`, `verbatim_doc_comment` | Help presentation |
| `value_hint = usage::ValueHint::FilePath`, `extensions("toml")`, `complete = function` | Completion behavior |
| `deprecated = "…"`, `deprecated_warn_at = "…"`, `deprecated_remove_at = "…"` | Still parses; reported when given |
| `effect = "…"`, `setting = "key"`, `select` | Effect raised when supplied; config binding; output selector |
| `action = usage::ArgAction::Help` (`HelpShort`, `HelpLong`, `HelpAll`, `Version`) | Put a built-in behavior on a flag you declare yourself |

Per-field resolution after the argv pass: command line, then `env`, then
a matching `default_if`, then `default`. Only the command that actually
ran is validated.

### Subcommands

- The enum derives `Subcommands`; variants wrap an `Args` struct
  (`Install(Install)`, `Install(Box<Install>)`), hold nothing
  (`Sponsors`), or declare fields inline (`Add { path: String }`).
- Variant names kebab-case into command names; `#[usage(name = "…")]`
  overrides. Variant attributes: `name`, `alias`, `alias_hidden`, `hide`,
  `effect`, `help`, `long_help`, `help_heading`, `display_order`,
  `deprecated`, `example`, `external_subcommand`.
- Nesting: an `Args` struct can carry its own `#[usage(subcommand)]`
  field, to a depth of 16.
- The same `Args` type may sit under several variants.
- `#[usage(flatten)]` joins tables at compile time; the KDL writes the
  struct as a `flagset` with a `use` on each command. A flattened struct
  cannot declare subcommands, and relationships crossing the boundary are
  lossy — keep a post-parse check for those.
- `#[usage(external_subcommand)] External(Vec<String>)` catches unmatched
  words plus the rest of argv (`Vec<OsString>` also works; one such
  variant only). Known subcommands and `default_subcommand` win first.

`ValueEnum` replaces hand-written `choices`:

```rust
#[derive(usage::ValueEnum)]
enum Shell {
    /// Bourne Again shell
    #[usage(visible_alias = "b")]
    Bash,
    #[usage(alias = "shell-z", hide = true)]
    Zsh,
    #[usage(name = "pwsh", help = "PowerShell")]
    PowerShell,
}
```

Variant names kebab-case into the accepted words; `#[usage(ignore_case)]`
on the enum relaxes matching. The derive binds words to variants, so no
`FromStr` is needed.

### Dispatch

The `match cli.command { … }` after parsing is optional. With
`#[usage(run)]` on the enum the derive generates it, and each command
struct implements the trait:

|  | No context | With a context |
| --- | --- | --- |
| Sync | `Run`, `#[usage(run)]` | `RunWith<Ctx>`, `#[usage(run_with)]` |
| Async | `RunAsync`, `#[usage(run_async)]` | `RunAsyncWith<Ctx>`, `#[usage(run_async_with)]` |

```rust
impl Run for Install {
    type Output = miette::Result<()>;
    fn run(self) -> Self::Output { install(&self.tools, self.force) }
}
```

- `Output` is taken from the first variant and every variant must agree;
  `()`, `ExitCode`, and any `Result` are fine.
- A unit or inline variant dispatches through a generated `{Enum}{Variant}`
  struct (`CommandsSponsors`); implement the trait on that.
- A root that also has flags gets `run_command()` (or `run_command_with`,
  `run_command_async`, …) rather than an `impl Run`, so the flags can be
  read first: `let cli = Ex::parse(); cli.run_command()`.
- An `Args` container whose only field is a required `#[usage(subcommand)]`
  gets a forwarding `impl Run` when it carries `#[usage(run)]`.
- `#[usage(no_ctx)]` on a variant in a `run_with` enum lets that command
  implement plain `Run`; the enum gains `run_with_lazy(|| build_ctx())`.
- Mixed: `#[usage(run_async)]` on the enum with `#[usage(run)]` on the
  sync variants. Never put `run` and `run_async` both on the enum.
- A catch-all: `#[usage(run, external = fallback)]` with
  `fn fallback(argv: Vec<OsString>) -> Output`.

Dispatch is invisible to the spec, help, and KDL.

### Entry points

| Need | Call |
| --- | --- |
| Process argv, help/version/errors handled and exited | `Cli::parse()` |
| Words after argv0, errors returned | `Cli::parse_from(&[&OsStr]) -> Result<Self, usage::Error>` |
| Full argv with argv0 (multicall and views applied) | `Cli::parse_from_argv(&[&OsStr])` |
| clap-shaped call sites | `Cli::try_parse_from(&[&OsStr])` |
| Merge new argv into an existing value | `cli.update_from(&argv)`, `cli.try_update_from(&argv)?` |
| Collect deprecation warnings | `Cli::parse_from_with_warnings(&argv, &mut warnings)` |
| Embed without exiting the process | `Cli::embedded_outcome(&argv) -> Outcome<Self>` |
| Static tables / spec metadata | `Cli::command()`, `Cli::spec()` |
| The spec as KDL | `Cli::to_kdl() -> String` |

`parse()` prints help to stdout with status 0, version as `{bin}
{version}`, failures to stderr with status 2 (clap's status), renders
deprecation warnings to stderr, and answers the hidden `__usage_spec__`
and `__complete_word__` requests before parsing anything.

With `parse_from`, help and version come back as errors, which is the
interception point for anything that must run between parsing and
dispatch:

```rust
use usage::Error;

match Ex::parse_from(&argv) {
    Ok(cli) => run(cli),
    Err(Error::Help { cmd, long }) => print!("{}", Ex::render_help(cmd, long).unwrap()),
    Err(Error::Version { long }) => println!("ex {}", env!("CARGO_PKG_VERSION")),
    Err(error) => {
        eprint!("{}", Ex::render_failure(&argv, &error));
        std::process::exit(2);
    }
}
```

`Error` is `#[non_exhaustive]`; keep the fallback arm. Named variants
include `UnknownFlag`, `MissingFlagValue`, `UnexpectedArg`,
`MissingRequired`, `DuplicateFlag`, `InvalidChoice`, `InvalidValue`,
`VarTooFew`, `VarTooMany`, `ConflictingFlags`, `MissingGroup`,
`MissingSubcommand`. `usage::diagnostic::report(spec, &argv, &error)`
gives a structured report with a code and byte offsets.

### Validation and groups

- `choices`, `var_min` / `var_max`, `delimiter` (split before every
  check), `conflicts`, `requires`, and the `required_*` family run after
  binding. Contradictory declarations — `choices` on a `bool`, a default
  outside its choices, `var_min > var_max` — are compile errors.
- `overrides` discards the loser's value but still checks it against
  choices. `conflicts` reports instead.
- `exclusive` refuses everything supplied alongside, positionals
  included; env-supplied values count as company, defaults do not.
- Groups: `#[usage(group("input", required))]` on the struct and
  `#[usage(long, group = "input")]` on members. Two members of a
  non-`multiple` group is `ConflictingFlags`; none of a `required` group
  is `MissingGroup`.
- An `ArgGroup` enum turns a group into a typed field: unit variants are
  switches, one-field tuple variants take a value; `Option<G>` optional,
  `G` required, `Vec<G>` with `#[usage(name = "…", multiple)]` keeps argv
  order.
- `validate_with = function` for cross-field checks; return
  `ValidationError::field("--destination").value(v).reason("…")`. Derive
  `Clone` when combined with the update entry points.

## The spec

### Emission

`Cli::to_kdl()` renders the spec from the same static metadata the parser
runs on, and every binary answers the word `__usage_spec__` with it:

```sh
mycli __usage_spec__ > mycli.usage.kdl
```

The word must come first on the command line; anywhere else it is a
value. It is not declared, not in the tables, and does not appear in the
document. KDL is the only format the binary emits; pipe through
`usage generate json -f -` for JSON.

Committing the spec next to the source makes the interface reviewable in
diffs, gives non-Rust tooling something to read, and lets `usage diff`
gate releases. Hold it in place with a test:

```rust
#[test]
fn committed_spec_matches_emitted_spec() {
    assert_eq!(include_str!("../mycli.usage.kdl"), Cli::to_kdl());
}
```

and regenerate it from a task such as:

```sh
cargo run --quiet -- __usage_spec__ > mycli.usage.kdl && usage lint mycli.usage.kdl
```

The emitted document is complete: the derive lowers every attribute into
a spec node, so nothing is lost between Rust and KDL except an example's
`lang`. In debug builds `to_kdl()` also asserts the tree is coherent (no
duplicate keys, no duplicate spellings across a `flatten`, nothing after
an unbounded variadic). `spec_extra` is the escape hatch for raw KDL and
is not parsed at compile time, so pair it with the round-trip test:

```rust
#[test]
fn spec_is_valid() {
    let spec: usage_parser::Spec = Cli::to_kdl().parse().unwrap();
    let _ = spec;
}
```

```toml
[dev-dependencies]
usage-parser = { package = "usage-lib", version = "6" }
```

`usage-lib` is the dynamic spec interpreter the CLI is built on. It can
parse a KDL spec at runtime and parse argv against it
(`usage_lib::parse(&spec, &argv) -> ParseOutput`, with flag and arg
values keyed by name), which is the path for a program that constructs
its CLI at runtime; it is never a dependency of a derive-based binary.

### KDL reference

Value syntax: strings `"x"`, raw strings `#"""…"""#`, booleans `#true` /
`#false`, bare integers, properties `key=value`, positional strings
`node "a" "b"`, children in `{ }`. Every help field can be an inline
property (`help="…"`) or a child node (`long_help "…"`).

```kdl
name "mycli"
bin "mycli"
version "1.0.0"
about "some help"
unknown_flags "error"

flag "-v --verbose" help="Enable verbose logging" global=#true count=#true
flag "-u --user <user>" help="User to run as" env="MYCLI_USER"

cmd "config" help="Manage the CLI config" {
  cmd "add" help="Add/set a config" {
    alias "set"
    arg "<key>" help="The key for the config"
    arg "<value>" help="The new config value"
    flag "-f --force" help="Overwrite existing config"
  }
  cmd "remove" help="Remove a thing" effect="destructive" {
    alias "rm"
    alias "delete" hide=#true
    arg "<name>" help="The name of the thing"
  }
}
```

Root nodes: `min_usage_version` (first line, when using newer nodes),
`name`, `bin`, `version`, `long_version`, `author`, `license`,
`repository`, `about` / `long_about` / `about_md`, `before_help` /
`after_help` (+ `_long_`), `usage` (replaces the synopsis), `example`,
`source_code_link_template`, `include file="…"` (merged, later wins),
`flagset` / `use`, `output` / `select` / `exit_code`, `help_template`,
`default_subcommand`, `multicall`, `view`, `mount`, `config`, `complete`,
and every command policy (`unknown_flags`, `external_subcommand`,
`arg_required_else_help`, `disable_*`, `subcommand_negates_reqs`,
`args_conflicts_with_subcommands`, `subcommand_precedence_over_arg`,
`allow_missing_positional`, `dont_delimit_trailing_values`,
`args_override_self`) except `restart_token`, which is command-only.

**`cmd "name"`** properties: `help`, `long_help`, `help_md` (+ `before_` /
`after_` forms), `hide`, `subcommand_required`, `subcommand_help_heading`,
`subcommand_value_name`, `next_line_help`, `flatten_help`,
`display_order`, `help_heading`, `term_width`, `max_term_width`,
`effect`, `deprecated` (+ `_warn_at`, `_remove_at`), `restart_token`,
and the policies above. Children: `alias "a" "b"` (`hide=#true` per
alias), nested `cmd`, `arg`, `flag`, `use`, `group`, `clause`, `example`,
`heading "Title" help="prose"`, `mount run="…"`, `complete`, `output`.

**`arg`** name string: `"<name>"` required, `"[name]"` optional, trailing
`...` variadic, `"<-- name>"` for `double_dash="required"`, `"<start>
<end>"` fixed arity. `<file>` and `<dir>` placeholders get file and
directory completion by default. Properties: `help`, `long_help`,
`help_md`, `help_heading`, `default`, `env`, `display_order`, `validate`,
`validate_error`, `effect`, `sigil="+"`, `var`, `var_min`, `var_max`,
`delimiter`, `allow_negative_numbers`, `value_terminator`, `double_dash`,
`hide`, `required`. Children: `choices`, `value_names`, `env_fallback`,
`deprecated_env`, `note`, `warning`, `requires`, `conflicts`,
`required_if`, `required_if_eq`, `required_if_eq_all`,
`required_unless`, `required_unless_all`.

**`flag`** name string: spellings separated by spaces (`"-f --force"`),
extra long names are aliases, an optional `<value>` placeholder makes it
value-taking, `"--include... <pattern>"` is repeatable, `"--include
<pattern>..."` is variadic per occurrence, `"--range <start> <end>"` is
fixed arity. Properties: `help` (+ variants), `global`, `required`,
`default` (`#true` for a switch), `count`, `negate="--no-x"`, `env`,
`var`, `var_min`, `var_max`, `delimiter` (needs `var=#true`),
`overrides`, `conflicts`, `requires`, `required_if`, `required_unless`,
`exclusive`, `allow_hyphen_values`, `allow_negative_numbers`,
`value_terminator`, `require_equals`, `default_missing`,
`value_optional` (presentation only), `bool_value`, `action` (`help`,
`help_short`, `help_long`, `help_all`, `version`), `builtin`, `effect`,
`deprecated` (+ gates), `hide`, `display_order`, `help_heading`.
Children: `alias "-u"`, `arg "<user>"`, `choices`, `env_fallback`,
`deprecated_env`, `conflicts`, `requires`, `requires_if "VALUE" "--flag"`,
`required_if_eq`, `required_if_eq_all`, `required_unless_all`,
`default_if "--json" "true"`, `note`, `warning`.

**`choices`**: `choices "a" "b"`, `choices strict=#false "a" "b"` to
suggest without enforcing, `choices ignore_case=#true { choice "always"
help="…" { alias "yes" } choice "never" hide=#true }` for rich values,
`choices env="VAR"` to read a comma- or whitespace-separated list at
runtime.

**`flagset "name" { flag … }`** at the top level and `use "name"` inside
any command (or another flagset) share flags without repeating them. It
is resolved while the spec is read, so consumers see ordinary flags; a
command's own declaration beats the set's on overlap; cycles and unknown
names are errors; a set holds flags only, never args.

**`group "input" "--file" "--url" "--stdin"`** with `required=#true` and
`multiple=#true`: neither means at most one, `required` exactly one,
both at least one. Members are selectors (`--long`, `-s`, or a positional
name); at least two.

**`complete "argname" run="…"`** or `type="…"` supplies completion
candidates for every arg of that name. `run` is a `sh -c` command
rendered as a tera template with `words`, `CURRENT`, `PREV`, and the
`shell_quote` / `shell_join` filters; `descriptions=#true` splits each
line on `:`. Built-in types: `file`, `path`, `path:toml,yaml`, `dir`,
`executable`, `command`, `command_args`, `config_keys`, `config_values`,
`username`, `hostname`, `url`, `email`, `none`, `unknown`.

**`effect`** on a command, flag, or arg is `read`, `write`, or
`destructive`; the effect of an invocation is the maximum of the command
and everything supplied. It is not inherited by subcommands, absent means
unknown, and it can only be raised, never lowered.

**`mount run="cmd"`** merges the KDL another command prints into this
one, for dynamically defined subcommands; it runs for help and completion
up front and for a parse only when a word matches nothing declared.

**`config { file … ; prop "key" type="…" default=… { cli "--x"; env
"X" } }`** declares settings resolved from command line, environment,
files (nearest first), and default, with `merge="union"`, `scope`,
`renamed_to`, and deprecation gates. It feeds `usage generate
json-schema` and the settings reference in generated docs.

**`output "json" framing="json"`**, `select "--format"`, and
`exit_code 0 "meaning"` declare what a command writes and how it exits,
for docs, SDKs, and agents.

### How argv is read

One pass, left to right, no reordering:

1. After a bare `--`, every token is a value. Only the first `--` is a
   separator.
2. A flag-like token (`-` plus more) matches a long or short flag in
   scope; no prefix inference, `--for` never means `--force`. Negative
   numbers and a lone `-` are values.
3. Any other word selects a subcommand if one matches by name, then
   alias; otherwise it feeds positionals in declaration order. Once a
   word has been consumed by a positional, a later word naming a
   subcommand is a value.

Value forms: `--jobs=8`, `--jobs 8`, `-j8`, `-j=8`, `-j 8`. `--jobs=`
binds the empty string. A detached value may not look like a flag unless
`allow_hyphen_values`; `--jobs --force` is a missing value. Short flags
bundle (`-abc`), and a value-taking letter ends the bundle. A repeatable
flag (`var`) takes one value per occurrence; a variadic occurrence
consumes tokens until the next flag-like token, `--`, or `var_max`, and
so eats positionals.

Flag scope runs downward: a command's flag may appear anywhere that
command is in scope, including before its subcommand words; `global`
extends it to every descendant, once per level with the innermost
winning. An env var supplies a boolean flag only when set to `1`, `true`,
`True`, or `TRUE`.

Error codes: `unknown_flag`, `missing_flag_value`,
`missing_required_flag`, `missing_required_arg`, `unexpected_arg`,
`invalid_choice`, `arg_requires_double_dash`, `var_too_few`,
`var_too_many`, `conflicting_flags`.

`usage explain -f spec.kdl -- mycli -j8 build a` shows which token bound
where, where every value came from, and what failed — without running
anything, and exiting 0 even for a line that does not parse.

## The usage CLI

Most subcommands read a spec from `-f <file>`, `-f -` for stdin, or a
script whose `#USAGE` comments declare one; `--spec "<kdl>"` passes it
inline where supported. A Rust binary needs no file:

```sh
mycli __usage_spec__ | usage generate markdown -mf - --out-dir docs
```

| Command | Purpose |
| --- | --- |
| `usage generate completion <shell> <bin>` (`g c`) | Completion script for bash, zsh, fish, nu, powershell |
| `usage generate completion-init <shell>` | One rc line that completes every `#!/usr/bin/env -S usage …` script on PATH (bash, zsh, fish) |
| `usage generate markdown` (`g md`) | One page, or `--multi --out-dir` for a page per command |
| `usage generate manpage` (`g man`) | roff; `-o file.1`, `--section 5` for a config page |
| `usage generate json` | The spec as JSON, includes merged and defaults filled |
| `usage generate json-schema` | JSON Schema for the config file from the `config` block |
| `usage generate sdk -l typescript\|python -o dir` | Typed subprocess client |
| `usage generate go -f spec -o tables.go` | Parse tables for a Go CLI (`//go:generate`) |
| `usage generate fig` | Fig / Amazon Q spec |
| `usage lint <file>` | Mistakes that still parse; `--format json`, `-W`, `--sorted` |
| `usage diff <old> <new>` | Interface changes between two specs; exits 1 on a breaking one |
| `usage explain -f spec -- <argv>` | What a command line binds to |
| `usage complete-word -f spec -- <words>` | Candidates for a partial line (what the scripts call) |
| `usage mcp -f spec` | Serve `list_commands` and `describe_command` over MCP |
| `usage bash\|zsh\|fish\|powershell <script>`, `usage exec <interp> <script>` | Run a script whose spec lives in its comments |

### Completions

A generated script is a shim: on every Tab it hands the words typed so
far to `usage complete-word`, so `usage` must be installed wherever the
script is (`--usage-bin` / `JDX_USAGE_BIN` names a non-PATH binary). The
spec comes from `-f` or from `--usage-cmd "mycli __usage_spec__"`, which
keeps the script matching whatever version is installed;
`--cache-key <version>` caches that output per key.

```sh
usage g completion fish mycli -f ./mycli.usage.kdl --install
usage g completion zsh mycli --usage-cmd "mycli __usage_spec__" > ~/.zsh_completions/_mycli
```

`--install` writes the script where the shell looks and nothing else: no
rc file is edited, and the one-time line a shell needs (zsh `fpath+=`,
PowerShell dot-source) is printed. A file usage did not write is refused
unless `--force`. Bash scripts need bash-completion 2.11 or newer sourced
first.

A Rust binary built with the `completions` feature and
`#[usage(completion)]` does not need the `usage` CLI at all: the script
calls the binary back with a hidden `__complete_word__` request, and
`parse()` answers from the same tables it parses with. Candidates come
from subcommands, visible flags, `choices`, `ValueEnum` words, negation
spellings, `value_hint`, and custom completers:

```rust
fn tasks_in_file(
    partial: &<Tasks as usage::spec::CommandArgs>::Partial,
    _context: &usage::complete::CompleteCtx<'_>,
) -> Vec<usage::complete::Candidate<'static>> {
    read_tasks(partial.file.as_deref())
        .map(|task| usage::complete::Candidate::described(task.name, task.about))
        .collect()
}

#[usage(arg, name = "TASK", complete = tasks_in_file)]
task: Option<String>,
```

The partial parse hands the completer the half-parsed struct, so a
`--file` earlier on the line can steer the candidates. Generated helpers:
`Cli::completion_script(usage::complete::Shell::Fish)`,
`completion_script_for_alias("m", shell)`,
`Cli::install_completion(shell, &usage::install::Env::from_process(),
usage::install::OnForeign::Refuse)`. Install never edits startup files
and never detects the shell.

### Docs and manpages

```sh
usage g markdown -f ./mycli.usage.kdl --out-file ./docs/cli.md
usage g markdown -mf ./mycli.usage.kdl --out-dir ./docs --url-prefix /cli/reference
usage g man -f ./mycli.usage.kdl -o mycli.1
usage g man -f ./mycli.usage.kdl | man -l -
```

Multi-page output nests directories the way commands nest, with
`index.md` at the root. Every part comes from a Tera template;
`--template spec=./spec.md.tera` (names: `spec`, `index`, `command`,
`argument`, `flag`, `config`) replaces one, and `{% include
"cmd_template.md.tera" %}` reuses the built-in command page. In the spec,
`about_md` / `help_md` supply Markdown text, `example` nodes become an
Examples section, `source_code_link_template` adds a source link per
command, and `repository` shows on the root page.

### lint and diff

`usage lint` catches a flag or subcommand declared twice, a required
positional after an optional one, a variadic that is not last, a command
or flag with no help, and an example the spec cannot parse. `--sorted`
also enforces declaration order; pair it with `-W` in CI.

`usage diff old.kdl new.kdl` groups findings into breaking (a command
line that worked now fails, binds differently, or resolves to a different
value), compatible (something gained or relaxed), and metadata (help,
effect, deprecation). `version` is ignored on purpose. As a release gate:

```sh
git show "$(git describe --tags --abbrev=0)":mycli.usage.kdl > released.usage.kdl
mycli __usage_spec__ | usage diff released.usage.kdl - --breaking
```

Compare specs from the same generator version; a newer emitter that
learned to express more reports those as constraint changes.

### Scripts

A shell script carries its spec in comments and gets `--help`, parsed
arguments, and completion from the shebang alone:

```bash
#!/usr/bin/env -S usage bash
#USAGE flag "-f --force" help="Overwrite existing <file>"
#USAGE flag "-u --user <user>" help="User to run as"
#USAGE arg "<file>" help="The file to write" default="file.txt"

if [ "$usage_force" = "true" ]; then
  rm -f "$usage_file"
fi
echo "Hello, ${usage_user:-world}" >> "$usage_file"
```

Each flag and arg arrives as `usage_<name>`; a switch is the string
`true`; a variadic value is one string joined the way `shell_words`
quotes it, recovered with `eval "files=($usage_files)"`. Anything the spec
does not recognize is passed through as a value. `usage exec node
script.js` does the same for any interpreter with `//USAGE` comments, or
reads a `.<script>.usage.kdl` sidecar when one exists. Tab completion for
every such script on PATH comes from one line in the shell rc:

```fish
usage g completion-init fish | source
```

## Testing

```toml
[dev-dependencies]
usage = { package = "usage-rs", version = "6", features = ["test"] }
```

```rust
use usage::test::{self as harness, Outcome, Page};

// process-free parse assertions
let words = harness::argv(["-j", "4", "build", "release"]);
let cli = harness::parse(Ex::spec(), &words.words(), Ex::parse_from).unwrap();
assert_eq!(cli.jobs, Some(4));

let message = harness::parse(Ex::spec(), &harness::argv(["--jobs", "many"]).words(), Ex::parse_from).unwrap_err();
assert!(message.contains("invalid value 'many'"));

// help pages, aliases resolve, unknown path panics
assert!(harness::help(Ex::spec(), &["build"], Page::Long).contains("--out"));
insta::assert_snapshot!(harness::help_tree(Ex::spec(), Page::Long));

// completion candidates (needs the completions feature too)
assert_eq!(harness::candidates(Ex::spec(), "ex bui"), ["build"]);

// the compiled binary, from a test under tests/
let output = usage::test::command!("greet", "hello", "Jeff").assert_success();
assert_eq!(output.stdout_text(), "hello, Jeff\n");
```

`harness::outcome` returns `Outcome::Parsed`, `Help` (with `.stderr` and
`.code`), `Version`, or `Failed`. Pages come back without colour, and the
harness reports declared spec identity, not computed runtime names.

## Migrating from clap

The rewrite is mostly a rename:

| clap | usage |
| --- | --- |
| `#[derive(Parser)]` | `#[derive(usage::Cli)]` |
| `#[derive(Args)]` | `#[derive(usage::Args)]` |
| `#[derive(Subcommand)]` | `#[derive(usage::Subcommands)]` |
| `#[derive(ValueEnum)]` | `#[derive(usage::ValueEnum)]` |
| `#[command(...)]`, `#[arg(...)]`, `#[value(...)]` | `#[usage(...)]` |
| `#[command(name = "x")]` | `bin = "x"` |
| `action = ArgAction::Count` | `count` |
| `default_value = "…"` | `default = "…"` |
| `default_value_if("flag", "v", "d")` | `default_if("--flag", "v", "d")` |
| `default_missing_value` | `default_missing` |
| `value_delimiter = ','` | `delimiter = ','` |
| `value_parser = ["a", "b"]` | `choices("a", "b")` |
| `value_parser = function` | the field type's `FromStr`, or `validate = "…"` |
| `num_args(0..=1)` | `default_missing` or `Option<Option<T>>` |
| `conflicts_with`, `requires`, `overrides_with` | `conflicts("--x")`, `requires("--x")`, `overrides("--x")` |
| `required_if_eq`, `required_unless_present…` | `required_if_eq(…)`, `required_unless(…)`, `required_unless_all(…)` |
| `last = true` | `double_dash = "required"` |
| `trailing_var_arg = true` | `trailing_var_arg` |
| `#[arg(skip)]` | `#[usage(skip)]` |
| `#[command(group(ArgGroup::new("g").required(true)))]` | `#[usage(group("g", required))]` |
| `clap_complete::generate(...)` | `Cli::completion_script(shell)` |
| `Cli::try_parse_from(argv)` | `try_parse_from`, or `parse_from` (no argv0) / `parse_from_argv` (with argv0) |

Steps: swap the dependency, rename the derives and helper attributes (the
compiler rejects clap's namespaces and points at `#[usage(...)]`), add
`unknown_flags = "error"` to the root, and optionally replace the
`match cli.command` with `Run` impls.

What does not come across:

- Runtime builders: `Command`, `ArgMatches`, `CommandFactory`,
  `augment_args`, `FromArgMatches`. A library that publicly returns
  `clap::Command` needs an adapter or an API change. `usage-lib` is the
  runtime interpreter for a CLI that genuinely builds itself at run time.
- `from_global`: read the global from the type that declares it and pass
  it as context (`RunWith`).
- `value_parser` closures: a Rust closure cannot travel in a portable
  spec.
- Prefix inference of long flags and subcommands, by design.
- Help templates and style palettes: rewrite against the ten
  `help_template` sections; terminal styling is automatic.
- Relationships crossing a `flatten` boundary and some positional
  relationships (`overrides`, value-source `requires_if`): keep a
  post-parse check.

`clap_usage` (crate `clap_usage`) turns an existing `clap::Command` into
a spec for a project that stays on clap: `clap_usage::generate(&mut
command, "mycli", &mut buffer)`, typically behind a hidden `--usage-spec`
flag. It cannot see `requires`, `default_value_if`, or
`default_missing_value` because clap has no getters for them.

## Gotchas

- Unknown flags are values and repeated scalar flags last-win unless the
  root says `unknown_flags = "error"` and `args_override_self = false`.
- `-h`, `--help`, `-V`, `--version` are supplied by the parser, never
  declared, and never in the spec. Declaring your own `--help` wins for
  that spelling and the other still answers.
- `parse_from` takes the words *after* argv0; `parse_from_argv` takes the
  whole thing. Passing argv0 to `parse_from` makes it a positional.
- `bool_value`: `--color=false` binds false, but a detached `--color
  false` leaves `false` for a positional.
- `value_optional` changes presentation only; to accept a bare flag use
  `default_missing` or `Option<Option<T>>`.
- `default_if` is a default: it satisfies `requires` but does not
  activate `requires_if`, and the target's own argv or env suppress it.
- `default_fn` emits no `default` into the spec, only `default_note` as
  prose, so the KDL cannot reproduce it.
- `num_args` and `value_names` bounds land on the nested `arg` in KDL
  (per occurrence); flag-level `var_min` / `var_max` count occurrences.
- A global flag given twice at the same level is `DuplicateFlag`; once
  per level, innermost wins, is fine.
- Positional parsing follows declaration order regardless of
  `display_order`.
- `__usage_spec__` must be the first word; the endpoint costs ~65 KB and
  `spec_endpoint = false` removes it while keeping `to_kdl()`.
- Completion install and `--install` never touch rc files; zsh still
  needs `fpath+=` and PowerShell a dot-source line.
- `usage diff` compares like with like: regenerate the released spec with
  the same `usage-rs` version before trusting a breaking finding.
- Config settings read booleans as `true/1/yes/y/on`, but an env var
  behind an argv flag sets it only for `1`, `true`, `True`, `TRUE`.
