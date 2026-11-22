# MOCHI

An archive format and archiver. **MOCHI 1.0 ships on the same model as WinRAR: a reusable
format library plus an end-user application**, here a desktop app for Windows and Ubuntu
and the `mochi` command line.

A `.mochi` file keeps every version of what you put in it, checks every byte it reads,
and says plainly what it could and could not verify.

> **A `.mochi` file is not a backup.** It is one file on one disk. Keep independent copies
> of anything you cannot recreate.

## Features

- **Versions.** Each save is a new version at the end of the file; older ones stay readable.
- **Checked reads.** Everything is verified against BLAKE3 fingerprints before use.
- **All-or-nothing saving.** An interrupted write never replaces the last good version.
- **Options at creation:** encryption, a recovery record (Reed–Solomon parity), or a
  TAR-compatible layout that `zstd` and `tar` can read.
- **Desktop app:** browse, create, extract, test and repair; open ZIP, 7z, RAR and TAR
  read-only; find and retrieve files across many archives.

The format is ratified at version 1.0 ([specification](docs/spec.md)).

## Download

Installers for Windows 10 22H2 / 11 and Ubuntu 22.04 / 24.04 (x86-64) are on the
**Releases** page. They are not code-signed (Windows shows "unknown publisher"); updates
are signed and checked by the app.

## Quick start

```bash
mochi create photos.mochi ~/Pictures/2026
mochi append photos.mochi new.jpg --delete 2026/old.jpg
mochi list photos.mochi
mochi get photos.mochi -C restored/
mochi verify photos.mochi
```

## Documentation

- [How MOCHI works](docs/user/how-it-works.md): start here
- [User guide](docs/user/README.md) and [command-line reference](docs/cli.md)
- [Specification](docs/spec.md), [ratification artifacts](docs/ratification/README.md), [schemas](docs/schemas/)
- [Developer documents](docs/README.md) and the [desktop app](apps/mochi-desktop/README.md)

## Building

```bash
cargo build --release -p mochi-cli     # Rust 1.91, pinned in rust-toolchain.toml
cargo test --workspace
```

The desktop app also needs Node 22+ with pnpm, and WebKitGTK 4.1 on Linux
([details](apps/mochi-desktop/README.md)).

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE). Third-party notices: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
