# What the checks prove

A check can show that **the bytes in this file still match what was recorded**, and only
for what it actually read. It cannot show that another copy exists.

## The commands

| Command | What it does |
|---|---|
| `mochi verify ARCHIVE [--level L]` | Checks the whole history, read-only. Default level: `restoration` |
| `mochi fsck ARCHIVE` | `verify`, plus every version opened and cross-checked on its own |
| `mochi restore-test ARCHIVE -C NEWDIR` | Extracts the latest version into a new folder, checking every file |
| `mochi health ARCHIVE` | Runs no check: summarizes what earlier checks on this machine recorded |

The app's **Test archive** is `verify`. Levels, each including the ones before:
`structural`, `referential`, `stored` (every stored byte read and its fingerprint
checked), `content` (decompressed and decrypted), `restoration` (every file reassembled
and its whole-file fingerprint compared).

## Reading the report

The report has one line per question, and the overall result never hides a failing line:

```
  integrity             PASS         required
  recoverability        PASS         required
  freshness             PASS         required
  searchability         UNSUPPORTED
result: PASS (exit 0)
```

| Status | Meaning |
|---|---|
| `PASS` | The check ran and found nothing wrong |
| `FAIL` | The check found damage |
| `DEGRADED` | Still usable, but a protection is reduced (for example damage a recovery record can repair) |
| `UNKNOWN` | Not enough evidence to say |
| `OVERDUE` | The last evidence is older than the policy allows |
| `UNSUPPORTED` | This version cannot do that check |

Only `PASS` is a pass. A check that did not run tells you nothing.

## What a `PASS` does not prove

* That any other copy exists, or that you could restore elsewhere.
* That this is the newest copy. **Freshness** compares the head with the last one this
  machine saw (or one you give with `--expected-head`); with neither it is `UNKNOWN`, and
  an older copy put in place of the archive cannot be detected.
* Anything about bytes it did not read: a `stored` run says nothing about decoding.
* That it will still pass tomorrow.

Without the passphrase, an Encrypted archive can only be checked at the `stored` level and
is never `PASS` overall. A wrong passphrase is `KEY_UNAVAILABLE` (exit 3), not a check
result.
