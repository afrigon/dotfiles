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
- **Git is mine.** Never commit or push; I review and commit manually.

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

## Improving this file

Auto memory is disabled — this file is the only thing that persists across
sessions. If I correct the same kind of thing more than once in a session,
or you notice recurring friction in how we work, ask me whether it should
become a rule here: propose the exact wording and let me approve it.
