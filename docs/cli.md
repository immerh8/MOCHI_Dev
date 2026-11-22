# The `mochi` command line

Every command and option is described by `mochi --help` and `mochi COMMAND --help`. This
page is the overview. The rules behind it are in the specification (`docs/spec.md` §23).

## Commands

| Command | What it does |
|---|---|
| `create ARCHIVE INPUT…` | A new archive with one commit. Never replaces an existing file. `--encrypted`, `--recovery-record PERCENT`, `--tar-compatible`, `--comment TEXT` |
| `append ARCHIVE [INPUT…] [--delete PATH]…` | One new commit: deletions first, then inputs. `--truncate-tail` removes an interrupted tail after keeping a verified copy |
| `list ARCHIVE [PATH] [--snapshot SEQ]` | What a version contains |
| `get ARCHIVE [PATH…] [-C DIR] [--snapshot SEQ]` | Extract, checking every file; never overwrites. `--stdout` writes one file to standard output |
| `snapshot list \| retain \| expire \| release` | Versions and their retention: legal holds, expiry |
| `verify ARCHIVE [--level L]` | Read-only health report (see [What the checks prove](user/verification.md)) |
| `fsck ARCHIVE` | `verify`, plus every version checked on its own |
| `restore-test ARCHIVE -C NEWDIR` | Extract the latest version into a new folder as a test |
| `health ARCHIVE [--policy FILE]` | Summary of what earlier checks on this machine recorded; runs no check |
| `search ARCHIVE [PATTERN]` | Find names in one archive, in one or every version |
| `find PATTERN FOLDER…`, `find --name P… FOLDER…` | Find names across every archive under some folders, read-only. `--names-from FILE`, `--match-case`, `--whole-name`, `--files-only`, `--folders-only`, `--no-subfolders` |
| `comment ARCHIVE` | Print the archive comment |
| `checkpoint ARCHIVE` | Write a full catalog copy so the archive opens fast |
| `compact ARCHIVE --output NEW` | Rewrite every version into a new archive |
| `gc plan` / `gc apply ARCHIVE --plan PLAN --output NEW` | Leave expired versions out of a new archive |
| `repair plan` / `repair apply ARCHIVE --plan PLAN --output NEW` | Repair into a new archive. `--copy PATH` uses other copies, `--salvage` scans raw bytes |
| `rekey ARCHIVE --list \| --add-passphrase \| --remove-passphrase ID \| --reencrypt -o NEW` | Passphrases of an Encrypted archive |
| `migrate ARCHIVE --output NEW` | Convert a pre-1.0 (draft 2) archive |
| `dump-index ARCHIVE` | Row counts of the catalog, for inspection |

Not in 1.0, exit 4: `inventory`, `split`, `join`, `mount`.

## Rules every command follows

* **Read-only means read-only.** `verify`, `fsck`, `list`, `search`, `find` and the plans
  never write to an archive. Commands that rewrite (`compact`, `gc apply`, `repair apply`,
  `migrate`, `rekey --reencrypt`) write a new archive and leave the source alone.
* **Nothing is overwritten.** A destination that exists is refused (`DESTINATION_EXISTS`),
  and `get` skips names that are already there and lists them.
* **Links are never followed**, when adding files or when extracting.
* **Passphrases** come from `--passphrase-file PATH` (repeatable), a prompt, or
  `--passphrase-env-for-automation`; never from an argument.
* **Freshness.** The last head seen for each archive is kept in a state folder
  (`--state-dir`, `$MOCHI_STATE_DIR`, or the platform default) so `verify` can notice an
  older copy. `--no-local-history` turns this off; `--expected-head ID` gives a head to
  compare with.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Done; every required check passed |
| 1 | Damage or a policy failure was found |
| 2 | Partial or unconfirmed: `DEGRADED`, `UNKNOWN`, `OVERDUE`, entries skipped, a search that could not cover everything |
| 3 | Wrong usage or an operational error (a missing folder, a wrong passphrase) |
| 4 | Not supported by this version (a pre-1.0 archive, a post-1.0 command) |

When several apply, the first in the order 1, 3, 4, 2, 0 wins.

## JSON output

`--json` prints one JSON object per run, tagged with its `schema` (for example
`mochi-cli-find-v2`). Every schema is in [`docs/schemas/json/`](schemas/json/README.md)
and is frozen: a change gets a new name. An error is
`{"error": {"code": "…", "message": "…"}}`, with stable codes.
