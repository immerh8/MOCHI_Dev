# MOCHI desktop app

A WinRAR-style archiver for `.mochi` archives, built with Tauri 2 (Rust) and React with
strict TypeScript on Vite. It browses every version of an archive; creates, adds,
removes, extracts, tests and repairs; handles encryption, recovery records and name
search; finds and retrieves files across many archives; opens ZIP, 7z, RAR and TAR
read-only and writes ZIP and TAR; integrates with Explorer and the Linux file managers;
and ships an updater, an offline user guide and English, Thai and Simplified Chinese.

Platforms: Windows 10 22H2 / 11 and Ubuntu 22.04 / 24.04, x86-64.

## Layout

```text
src-tauri/            Rust backend: thin Tauri commands over mochi-core
  capabilities/       least-privilege permissions for each window
  src/                one module per area (browse, write, extract, check, find, retrieve,
                      foreign, rekey, update, ...); ipc.rs holds the IPC types
ui/                   React frontend
  src/<area>/         one folder per screen; messages.ts files hold the wording rules
  src/i18n/           message catalogues (en, th, zh-CN)
  src/ipc/generated/  TypeScript types generated from Rust (never edited by hand)
e2e/                  end-to-end tests (WebdriverIO + tauri-driver)
```

## Build, run, test

On Ubuntu install the WebKitGTK 4.1 packages first:

```bash
sudo apt-get install libwebkit2gtk-4.1-dev libxdo-dev libssl-dev librsvg2-dev libayatana-appindicator3-dev
```

```bash
pnpm --dir apps/mochi-desktop/ui install --frozen-lockfile
pnpm --dir apps/mochi-desktop/ui dev       # terminal 1: the Vite dev server
cargo run -p mochi-desktop                 # terminal 2: the app

cd apps/mochi-desktop/ui && pnpm lint && pnpm typecheck && pnpm test   # UI checks
cargo test -p mochi-desktop      # Rust tests; also regenerates ui/src/ipc/generated (commit it)
```

End-to-end tests need a release frontend build and `tauri-driver`; the `desktop e2e` CI
job in `.github/workflows/ci.yml` shows the exact steps; installers are built with `packaging/build-installer.sh`.

## Security model

* **The webview names no path.** Files and folders are chosen in native dialogs shown by
  Rust, and the page refers to them by handles. No filesystem, shell, HTTP or dialog
  permission is granted to the webview, and the CSP allows no remote content.
* **Commands are thin.** They validate input, call `mochi-core` and return typed results;
  there is no format logic in the UI.
* **Archive text is untrusted.** Names, comments and messages from archives are escaped in
  Rust and rendered as text only; `dangerouslySetInnerHTML` is banned by lint and CI.
* **Foreign formats** are parsed only in the isolated helper process (`crates/mochi-foreign`).
* **Passphrases** cross IPC once into zeroizing types in Rust and are never stored.
* **One window per archive**; each window's archives, jobs and passphrases are its own and
  are released when it closes.
* **Long work runs as jobs** off the async runtime, with progress over a Tauri `Channel`,
  pause and cancel.
* **Nothing leaves the machine** unless you ask: the update check is manual by default, and
  crash logs stay local.

Every new permission needs a reason in the pull request. The full rules are in
[CONTRIBUTING.md](../../CONTRIBUTING.md).
