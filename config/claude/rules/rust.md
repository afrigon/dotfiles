---
paths:
  - "**/*.rs"
---

# Rust

- Module layout: a directory module is `name.rs` next to `name/`, never
  `name/mod.rs`. `name.rs` declares the submodules — one type per file —
  and re-exports their types with `pub use`, so callers write
  `command::TimeRate`, not `command::time_rate::TimeRate`. The type a
  module is named after lives in `name.rs` itself (`simulation.rs` holds
  `Simulation`), never in `name/name.rs` (clippy's `module_inception`).
- Unit tests live at the bottom of the file they test, in
  `#[cfg(test)] mod tests`; tests of a crate's public behavior live in its
  `tests/` directory.
- New types where a mixup would compile but be wrong: ids, handles and
  indices into a specific collection, and quantities whose unit isn't
  obvious from context (`BodyIndex { value: usize }`,
  `MaterialHandle { index: usize }`, `SimulationTime { seconds: f64 }`).
  Other numbers stay primitives behind a descriptive field name. `usize`
  is only for indexing, lengths and in-memory sizes.
- No tuples in our own data shapes: named structs, not tuple structs or
  multi-field tuple variants. An enum variant wrapping exactly one struct
  (`SetTimeRate(SetTimeRate)`) is fine.
