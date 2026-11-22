# MOCHI user guide

| Page | |
|---|---|
| [Getting started](getting-started.md) | The commands, each with an example |
| [How MOCHI works](how-it-works.md) | What is inside a `.mochi` file, in plain words |
| [Archive options](archive-options.md) | Encrypted archives, recovery records, TAR-compatible archives |
| [What the checks prove](verification.md) | `verify`, `fsck`, `restore-test`, `health` and the status words |

Command reference: [docs/cli.md](../cli.md). The desktop app does the same work through its
own screens; its **Test archive** is `verify`.

## A `.mochi` file is not a backup

A `.mochi` file is one file on one disk. It keeps every version and can check that what
it holds still matches what was written, but it cannot protect itself from the loss of
the file.

* After `create` or `append`, `LOCAL_COMMITTED` means saved **in this file, on this disk**.
* Deleting a file removes it from the newest version only; earlier versions keep it.
* A passing `verify` checks this file; it says nothing about other copies.
* A recovery record repairs bounded damage; it is not a second copy.
* With encryption, a lost passphrase is lost data.

Keep independent copies of anything you cannot recreate: ideally three, on storage that
does not fail together, one in another place and one offline (spec §1.1, §15.3).
`mochi repair --copy` can use those copies, but making them is up to you.

## Format status

The format is **ratified at 1.0** (spec §28). Archives written by builds before 1.0 use a
draft layout that every command refuses (exit 4) except `mochi migrate`, which converts
draft 2:

```bash
mochi migrate old.mochi --output new.mochi
```

`migrate` verifies the source first, never changes it, and checks the new archive before
publishing it. Not in 1.0 (exit 4): `inventory`, `split`, `join`, `mount`, key files and
public-key encryption, split volumes, remote storage, and signatures.
