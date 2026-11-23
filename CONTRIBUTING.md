# Contributing to MOCHI

MOCHI is an archive format: a mistake can make someone's data unreadable years later, so
changes are reviewed against the rules below as well as the tests.

The [specification](docs/spec.md) is normative. Files in
[`docs/ratification/`](docs/ratification/README.md) are frozen: a change to any byte or
rule there is a new format identifier, never an edit. If the spec does not answer a
question, open an issue rather than guessing.

## Checks

```bash
cargo fmt --all --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace
ci/check-invariants.sh
cd apps/mochi-desktop/ui && pnpm install --frozen-lockfile && pnpm lint && pnpm typecheck && pnpm test
```

`cargo test -p mochi-desktop` regenerates the TypeScript IPC types in
`apps/mochi-desktop/ui/src/ipc/generated`; commit them.

## Rules

- **Wire format.** Byte layouts and magic numbers follow the spec exactly; magic numbers
  and digest domain separators are defined once, in `mochi-format`. Golden fixtures are
  updated deliberately, never by blanket regeneration.
- **Publication and safety.** All I/O in `mochi-core` goes through the `Storage` trait. A
  partially written commit never becomes the head; after a failed sync the writer stops.
  Verification is read-only. Every object is hash-verified before it is parsed.
- **Untrusted input.** Archives are untrusted: bounds- and overflow-check before every seek
  or allocation, and never `unwrap`/`panic!` on archive data in library crates. Parser
  changes extend a fuzz target and add a vector.
- **`unsafe`** only in `mochi-foreign`, `mochi-sys` and `mochi-shellext`, each block with a
  `// SAFETY:` comment (`ci/check-invariants.sh` enforces this).
- **Encrypted profile.** Secrets live in `zeroize` types and are never logged, printed or
  put in an error; a passphrase is never a command-line argument; nonces are always fresh.
- **Reporting.** Only the spec's status values; a check that did not run is never `PASS`.
  Error codes are stable. Never describe an archive as "backed up", "safe" or "preserved".
- **Desktop app (Tauri).** No format logic in the UI or in commands; least-privilege
  capabilities with a reason for each new one; strict CSP; archive-supplied text is
  rendered as text only.
- **Foreign archive formats.** ZIP, 7z, RAR and TAR are parsed only in the `mochi-foreign`
  helper process. RAR is never written.
- **Dependencies** must be MIT- or Apache-2.0-compatible.

Feature code comes with a test of what can go wrong, not only the happy path. Pull
requests cite the spec sections they affect.

By contributing you agree that your contribution is licensed under the
[MIT license](LICENSE).
