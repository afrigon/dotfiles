# Working with me

I'm an experienced developer. I drive the design; you produce code I've
already understood and agreed to. Being technically right is not enough —
if I didn't get to weigh in, it's wrong.

## Process

- **Explain before you edit.** Immediately before each change, state what
  you're about to change and why — the constraint or problem motivating it.
  An edit must never be the first mention of a decision. A plan listed at
  the start of the turn doesn't count as explanation for a design choice
  buried inside it.
- **Design decisions are mine.** If a task requires a decision we haven't
  already made together — restructuring or renaming something, splitting or
  introducing variables/files/abstractions, changing an interface or data
  shape, picking between viable approaches — stop and present the options
  with trade-offs and your recommendation, then let me choose before
  writing any code. When in doubt whether something counts: it does.
- **No silent side-edits.** Never refactor, reformat, or "improve" code
  outside the agreed scope. If you spot something worth changing, say so
  and let me decide.
- **Plans must expose structure changes.** "Update X" is not a plan step if
  it hides a restructuring. Name every file you'll touch and every shape
  change you'll make.
- **Don't rabbit-hole.** When you're reasonably confident, act on it — no
  deep research spirals or re-validation loops. If you're genuinely unsure,
  say so and ask instead of researching around it.
- **Dependencies start at latest.** When adding a dependency, resolve its
  version through the package manager (`cargo add`, `npm install`, ...) so
  it lands on the latest release — never copy version pins from another
  project or from memory. Pin older versions only for a real compatibility
  constraint, and say so.
- **Cross-repository changes go through herdr.** When a task needs edits
  in a repository other than the current one, load the `herdr` skill,
  start a herdr workspace with a worktree on that repository, and land
  the change as a pull request — never commit to it directly.

## Git

- The repository checkout stays on `main`; work happens in a worktree.
  Inside herdr, that worktree comes from herdr — load the `herdr` skill.
  Outside herdr, use a plain branch or `git worktree` instead.
- Never work on the `main` branch unless explicitly asked to.
- On a branch, commit often — at natural checkpoints, and always before
  a large or risky change — so any point in the implementation is easy
  to return to.
- **Never `--amend` or rewrite a commit that has already been pushed.**
  New work is a new commit and a plain `git push`, so every checkpoint
  stays reachable. Force-pushing is acceptable only to restack a branch
  onto a moved base, or to purge a sensitive file — and say so before
  doing it. Never force-push to tidy history.
- Commit messages stay short: a subject line, with a few bullets when
  the commit spans multiple topics. Never an essay.
- An implementation task ends with a pull request. Don't open one for
  research, prototyping, or exploration.
- Pull requests: assign me (`--assignee @me`). Keep the body short
  enough that it actually gets read — bullet points where they help,
  detail only where there is real complexity. When the PR addresses an
  issue, include `Closes #<number>` so merging closes it.

## Code comments

- Default to zero comments. The code itself must be clean and
  self-documenting — clear names, straightforward flow — so that comments
  are useless. If a comment restates what readable code already says, it
  must not exist.
- Comment only genuinely niche, hard-to-understand details a competent
  reader would trip over — a constraint, trade-off, or gotcha. 1–2 lines.
- Doc comments (docstrings, DocC, JSDoc, rustdoc, ...) only on the public
  API of reusable libraries — never in application code.
- Never write comments addressed to me or a reviewer: no narrating what
  you changed, why the edit is correct, or what the next line does.

## Naming

- Full words, never abbreviations: `description` not `desc`, `protocol`
  not `proto`. Single-letter names are fine in tight local scope (loop
  indices, short lambdas).
- Follow the language's naming standard (snake_case vs. camelCase etc.);
  when a language has no standard, prefer camelCase. Established idioms of
  a language count as its standard (`err` in Go, `ctx` for a context).

## Domain terminology

- I often work in domains where I'm not an expert. In niche topics, expand
  abbreviations and explain terms a beginner would find confusing, on
  first use.
- Don't assume I'm a beginner at everything. If you're unsure what depth I
  need on a topic, ask once when the topic first comes up and calibrate
  from my answer.

## Durable writing

- Anything written to a file outlives the moment it was written. Never
  phrase content relative to "now" — no "recently", "currently", "new",
  "will soon", "for now". If a fact is time-dependent, rephrase so it
  isn't; if the information isn't critical, drop it rather than let it
  rot.

## Nothing AI-flavored in projects

- Never reference Claude, AI assistance, or CLAUDE.md in project files —
  code, comments, docs, commit messages. Conventions live *in* CLAUDE.md
  files, but nothing in the project may point *at* them; if a comment
  needs context that lives there, inline the minimal fact or drop the
  comment.

## Writing skills

- Skills must be portable and individually shareable: each one stands
  alone. Never reference another skill from inside a skill — no names, no
  "load the X skill" pointers.
- Routing lives outside the skills: the frontmatter description says when
  a skill gets loaded, and this file holds any wiring between them.

## My system

- Every machine runs the same core tooling: fish as the shell, nvim as the
  editor, and mise for CLI tool installs (starship, herdr, node, ...) —
  `mise which <tool>` locates the real binary.
- Dotfiles live in ~/src/dotfiles and are stowed into ~/.config by
  `mise run setup` (`stow --no-folding`). A new config file must be created
  in the repo and stowed, never written directly into ~/.config.
- Arch Linux machines: system packages via paru; Hyprland on Wayland,
  launched via uwsm.
- macOS machines: system packages via Homebrew.
- My GitHub repositories follow a documented standard covering naming,
  README, license, topics, gitignore, version pinning, and repository
  settings. Load the `repo-standard` skill before creating a repository,
  scaffolding a project, or changing any of those things in an existing one.

## Improving this file

Auto memory is disabled — this file is the only thing that persists across
sessions. If I correct the same kind of thing more than once in a session,
or you notice recurring friction in how we work, ask me whether it should
become a rule here: propose the exact wording and let me approve it.
