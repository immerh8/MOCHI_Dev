# Archive options

Three choices are made when an archive is created and are fixed for its life. An archive
cannot be both Encrypted and TAR-compatible; a recovery record combines with either.

## Encrypted

```bash
mochi create --encrypted --passphrase-file pass.txt vault.mochi photos
mochi list --passphrase-file pass.txt vault.mochi
```

Names, sizes, folders, attributes and content are sealed (XChaCha20-Poly1305) under a
random data key; each passphrase unlocks that key (Argon2id). Without `--passphrase-file`
the tool asks on the terminal. A passphrase is never a command-line argument.

* **A lost passphrase is lost data.** Nothing can recover it. Keep it somewhere separate
  from the archive and its copies. A wrong passphrase is `KEY_UNAVAILABLE` (exit 3).
* **Still visible without the key:** the number of commits, the number and sizes of stored
  objects, the key envelopes, and (because equal content is stored once) whether content
  you appended was already in the archive.
* **Without the key** only `verify` (stored bytes only, never `PASS` overall) and
  `rekey --list` work. Everything else, including `repair`, needs the passphrase.
  `mochi find` lists Encrypted archives as not searched.
* **Passphrases:** `mochi rekey --add-passphrase`, `--remove-passphrase`. Removing a
  passphrase is **not revocation**: old copies of the file, and its history, still open
  with it. `rekey --reencrypt -o NEW` writes a new archive under a new key.
* Rewrites (`compact`, `gc apply`, `repair apply`) seal again under a new key, so they need
  every passphrase the new archive should accept.

Spec §14, Annex B.2.10; `docs/ratification/R5-crypto-draft.md`.

## Recovery record

```bash
mochi create --recovery-record 10 rr.mochi big.bin    # PERCENT: 1 to 100
```

Every commit also writes Reed–Solomon parity of about PERCENT % of the bytes it adds. It is
a **repair aid, not a second copy**: losing the file loses its recovery record too.

* In each group of stored pieces, as many damaged pieces can be rebuilt as the group has
  parity pieces. More damage than that is reported (`PARITY_CAPACITY_EXCEEDED`) and nothing
  in that group is changed.
* A rebuilt piece is used only if it matches its recorded fingerprint.
* The newest footer is not covered, so damage at the very end of the file is the weakest
  point.

With damage inside capacity, `verify` shows integrity `FAIL` and recoverability
`DEGRADED`, and `repair` writes a repaired copy:

```bash
mochi repair plan rr.mochi --output rr.plan
mochi repair apply rr.mochi --plan rr.plan --output rr.fixed
```

Spec §7.4, §22 step 6; `docs/ratification/R6-erasure-coding-draft.md`.

## TAR-compatible

```bash
mochi create --tar-compatible t.mochi src
```

Every commit also writes a standard pax TAR stream, so tools other than MOCHI can extract
the archive. Tested in CI with zstd 1.5.7, GNU tar 1.34–1.35 and bsdtar 3.6–3.8:

```bash
zstd -dc t.mochi | tar -x --ignore-zeros -f - -C out                                 # GNU tar
zstd -dc t.mochi | bsdtar -x --options read_concatenated_archives -f - -C out       # bsdtar
```

* Both flags are required; without them a tool stops after the first commit.
* Generic tools show the **history**, not the latest version: a deleted file comes back,
  and a renamed file appears under both names. `mochi get` gives the latest snapshot.
* Costs space: no storing identical content once, and 512 bytes of framing per file.

Spec §7.2, Annex B.2.9.
