# Getting started

## Install

The installers from the Releases page include the desktop app and the `mochi` command:
on Windows `%LOCALAPPDATA%\MOCHI\bin\mochi.exe` (added to your PATH; open a new terminal
after installing), on Ubuntu `/usr/bin/mochi`. To build it yourself:
`cargo build --release -p mochi-cli` (the binary is `target/release/mochi`).

## The desktop app

With no archive open, the first screen offers **Create archive**, **Open archive** and
**Extract**. Drop files on the window to add them; drop a `.mochi` file to open it.
Extracting goes into a new folder next to the archive and never overwrites your files.
The toolbar has **Test** (checks the archive), **Find** (searches names inside many
archives) and **Info**; **More** has passphrases, repair, other archive formats and
settings.

## Create, change, list, extract

```bash
mochi create photos.mochi photos         # photos/ becomes a top-level entry
mochi append photos.mochi new.txt --delete photos/2026/old.txt
mochi list photos.mochi                  # the latest version
mochi list photos.mochi --snapshot 0     # an earlier version, still there
mochi snapshot list photos.mochi         # every version
mochi get photos.mochi -C restored       # everything, into ./restored
mochi get photos.mochi photos/a.txt --stdout
```

* `create` never replaces a file; if the archive exists it stops (`DESTINATION_EXISTS`).
* `append` writes one new version: deletions first, then the inputs. Deleted entries stay
  in earlier versions.
* `get` checks each file before writing it, never overwrites, and lists anything it
  skipped. Links, devices and sockets are skipped and listed, never followed.

## Check, search, maintain

```bash
mochi verify photos.mochi                # read-only health report; --json for scripts
mochi find report ~/Archives             # names in every archive under a folder
mochi search photos.mochi a.txt          # names in one archive, every version
mochi compact photos.mochi --output photos-new.mochi
mochi repair plan photos.mochi --output fix.plan
mochi repair apply photos.mochi --plan fix.plan --output photos-fixed.mochi
```

`compact`, `gc apply` and `repair apply` write a **new** archive and never change the old
one. What `verify` proves is in [What the checks prove](verification.md); options such as
encryption are in [Archive options](archive-options.md).

## Limits

One archive tracks up to about 342,000 files (fewer if files are large). At the limit,
reading and checking still work and new commits that add files are refused
(`CAPACITY_EXCEEDED`); split very large sets across several archives.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Done; every required check passed |
| 1 | A check found damage or a policy failure |
| 2 | Partly done, or something could not be confirmed (`DEGRADED`, `UNKNOWN`, entries skipped) |
| 3 | Wrong usage or an operational error (for example a wrong passphrase) |
| 4 | Not supported by this version |
