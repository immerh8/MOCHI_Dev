# Design decisions

Format decisions (D1–D31) are in the specification, `docs/spec.md` Annex B. This page
lists the product decisions (O1–O32) that code comments cite as "plan O*n*" or "O*n*",
and the bar a change has to meet.

Labels such as C6, D3, R6, T12 or W20 in comments and commit messages name the
development phase in which something was built: C for the core library, D for the
desktop app, R for the ratified format artifacts, T/W/K for later tasks.

## Design principles

* **All I/O through `Storage`.** Every read, append, sync and lock in `mochi-core` goes
  through one trait, so tests can tear, reorder, drop or halt writes.
* **Distinct byte types.** Decoded bytes, encoded plaintext, stored payload and stored
  objects are different Rust types, and each digest accepts only its own input.
* **One jobs layer.** Long operations take a progress sink and a cancellation token and
  return a typed report; the CLI and the app render the same report.
* **Stable error codes,** defined once in `mochi-core`.

## Definition of done

A change is done when an automated test in CI on Windows and Ubuntu shows it, not a demo:
crash and fault-injection tests for publication and recovery; corruption tests for
verification and repair; hostile-archive fixtures for anything that parses untrusted
input, with a fuzz target; a benchmark (dataset, hardware, cache state, settings) for any
cost the spec states; an end-to-end test for desktop behaviour. The detailed rules are
in [`AGENTS.md`](../../AGENTS.md).

## Product decisions

| ID | Decision |
|---|---|
| O1 | Desktop app: Tauri 2, React and strict TypeScript on Vite, pnpm with a frozen lockfile; IPC types generated from Rust with `ts-rs` |
| O2 | Canonical structures are deterministic CBOR (spec D2), one codec in `mochi-format` |
| O4 | TAR compatibility is opt-in, per archive, at creation (spec D4) |
| O5 | Split volumes are not in 1.0 (spec D5) |
| O6 | Attributes: POSIX mode, uid/gid, mtime; Windows read-only, hidden, system, archive and mtime. setuid/setgid only on explicit request (spec D6) |
| O7 | Interoperability is proven by an independent read-only verifier in Python, written from the spec alone (`interop/pyverify`, spec D7) |
| O8 | Freshness: no anchor is `UNKNOWN`; a user-given head or this client's last-seen head is the anchor, and the report names which (spec D8) |
| O9 | The app reads ZIP, 7z, RAR and TAR read-only, in an isolated helper process (spec D9) |
| O10 | Shell integration: Explorer context menu (Add to archive, Add to "<name>.mochi", extract entries, Find) and Linux file-manager actions |
| O11 | Supported platforms: Windows 10 22H2 and 11, Ubuntu 22.04 and 24.04, x86-64. No macOS in 1.0 |
| O12 | Claim only the durability the OS documents; Windows directory durability is `Unconfirmed` by default (spec D13, B.2.20) |
| O13 | Exit-code precedence: 1 > 3 > 4 > 2 > 0 |
| O14 | Minimum Rust 1.89; toolchain pinned to 1.91 |
| O15 | Error codes are registered once; the registry was frozen with R7 |
| O16 | Record envelopes: CBOR-native, plus a binary envelope for opaque payloads (spec D11) |
| O17 | A footer always follows its commit frame |
| O18 | Default reader limits match the frame payload budgets (spec B.2.3) |
| O19 | Object and file-version IDs are random 256-bit values from the OS, never derived from content |
| O20 | The file-content hash is plain BLAKE3, equal to `b3sum`; every other digest is domain-separated |
| O21 | Every data object is one Zstandard frame with its content size and checksum |
| O22 | Integrity failures exit 1, whichever command finds them |
| O23 | Project license MIT; dependencies MIT- or Apache-2.0-compatible; UnRAR only in `mochi-foreign`, read-only |
| O24 | Paths are byte components joined by `/`; Windows names are WTF-8; names are never normalized |
| O25 | The catalog is in-memory SQLite; images move as bytes through `Storage` |
| O26 | The recovery manifest is the commit's delta; checkpoints bind image, delta and full manifest (spec D10) |
| O27 | The archive descriptor is immutable, at offset 0, bound by every commit (spec D12) |
| O28 | Tail truncation: an eligibility screen, a verified quarantine copy first, recorded waivers (spec D14) |
| O29 | In Core, "file identity" is the path: finding a file by identity means its history across versions (`mochi search --path`). No separate ID survives a rename |
| O30 | Crash reports stay local; the app sends nothing |
| O31 | The app may create ZIP, `.tar`, `.tar.gz` and `.tar.zst` (in `mochi-export`); never RAR, not 7z |
| O32 | The archive comment is a commit-record field, repeated until changed; Encrypted archives have none (spec D29) |
