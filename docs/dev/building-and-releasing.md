# Building and releasing

## Installers

Windows: a per-user NSIS setup (with the WebView2 bootstrapper). Ubuntu: a `.deb` built
on 22.04, which also installs on 24.04. Both include the desktop app, the foreign-archive
helper, the `mochi` command, the user guide as offline HTML (`packaging/guide.py`) and a
license list.

```bash
cargo install cargo-about --version 0.9.2 --locked --features cli   # once
cargo install tauri-cli  --version 2.12.2 --locked                  # once
packaging/build-installer.sh deb      # on Ubuntu 22.04
packaging/build-installer.sh nsis     # on Windows (Git Bash)
```

Output goes to `target/release/bundle/{deb,nsis}/`. CI builds both on every pull request
and smoke-tests them (`packaging/smoke-deb.sh`, `packaging/smoke-nsis.ps1`): install,
check every file and registry entry, run `mochi --version`, uninstall.

**Licenses.** `packaging/licenses.py` lists every dependency's license; a license not in
the `accepted` list of `packaging/about.toml` fails the build. UnRAR's notice is in
`THIRD-PARTY-NOTICES.md`.

## Signing and updates

* The installers are **not code-signed**; Windows SmartScreen shows "unknown publisher".
* **Updates are signed** with minisign. The public key is `plugins.updater.pubkey` in
  `apps/mochi-desktop/src-tauri/tauri.conf.json`; the private key and its password are the
  Actions secrets `TAURI_SIGNING_PRIVATE_KEY` and `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`.
  The app checks the signature before installing anything.
* The app checks for updates only when asked (a check at start-up is an opt-in setting).
  It reads `latest.json` from the newest published release
  (`https://github.com/immerh8/MOCHI/releases/latest/download/latest.json`).

## Releasing

1. Set the version in `Cargo.toml` (`[workspace.package]`) and
   `apps/mochi-desktop/src-tauri/tauri.conf.json` (they must match), run
   `cargo update --workspace`, and add plain-text notes in
   `docs/release-notes/v<version>.txt`.
2. Run the `release` workflow (or push the tag `v<version>`). It builds and signs both
   installers, writes `latest.json` and creates a **draft** release. It never publishes.
3. Review the draft and publish it. Installed apps see the update once it is published.

Never reuse a version number. To withdraw a release, unpublish it and publish a higher
version.

Before a release, a person checks what CI cannot: installing on a Windows client,
Explorer's menu entries, double-clicking a `.mochi` file, drag and drop, and updating from
the previous version. The `installer-smoke` workflow (manual) covers the parts that need no
eyes in Windows 11, Windows 10 and Ubuntu virtual machines.

## Windows durability

Windows does not document that a new file's name survives a power cut after the folder is
flushed, so MOCHI reports a new archive's directory entry as unconfirmed on Windows by
default (spec B.2.6, B.2.20). The `g6-windows` workflow replays crashes at the block level
in Windows 11 and Windows 10 22H2 VMs (`ci/g6-windows/`): on NTFS a flushed new name
survived 3 of 3 replays, an unflushed one 0 of 3, and `MOVEFILE_WRITE_THROUGH` alone 0 of 3.
This is observed behaviour, not a documented guarantee, so the default stays unconfirmed;
a user may choose to trust a successful flush on local NTFS (`--trust-ntfs-directory-flush`, or Settings → Performance).
