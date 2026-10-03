---
paths:
  - "**/*.rs"
---

# Rust

- Module layout: a directory module is `name.rs` next to `name/`, never
  `name/mod.rs`. `name.rs` declares the submodules — one type per file —
  and re-exports their types with `pub use`, so callers write
  `command::TimeRate`, not `command::time_rate::TimeRate`.
- Unit tests live at the bottom of the file they test, in
  `#[cfg(test)] mod tests`; tests of a crate's public behavior live in its
  `tests/` directory.
- Domain values get named types with a named field — times, ids, quantities
  (`BodyIndex { value: usize }`, `SimulationTime { seconds: f64 }`). `usize`
  is only for indexing, lengths and in-memory sizes.
- No tuples in our own data shapes: named structs, not tuple structs or
  multi-field tuple variants. An enum variant wrapping exactly one struct
  (`SetTimeRate(SetTimeRate)`) is fine.
