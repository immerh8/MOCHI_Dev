# Golden fixtures

Byte-exact vectors and whole archives that the tests check MOCHI against. They are built by
`mochi-testkit` (never from randomness or the clock) and are **frozen**: a format change
updates only the fixtures it affects, deliberately, and the pull request explains each diff.
Archives written by older versions must keep opening, so these files are never regenerated
in bulk.

| Folder | What it holds |
|---|---|
| `c1/` | Frames and footers, valid and rejected |
| `c2/` | Objects and digest known answers |
| `c3/` | A catalog image |
| `c4/` | Recovery manifests |
| `c5/` | Commit records and small archives, including interrupted ones |
| `b2/` | Record envelopes and the archive descriptor |
| `c10/`, `c11/`, `c12/` | TAR-compatible, Encrypted and recovery-record vectors |
| `d29/` | Archive comment records |
| `r8/` | 76 whole archives, valid, damaged, truncated and interrupted, each with the report MOCHI must give (`*.summary.json`, indexed by `cases.json`); `legacy/` holds pre-1.0 archives for `mochi migrate` |

A folder's `vectors.txt`, where there is one, describes its files; the builders in
`crates/mochi-testkit` (`src/golden.rs`, and `tests/r8_golden/` for `r8`) document every fixture. The set includes hostile names
(such as `<img src=x onerror=…>`) so the app's text-only rendering stays tested.
`cargo test -p mochi-testkit --test r8_golden` checks the whole set; the independent
verifier in `interop/pyverify` reads the same archives in CI.
