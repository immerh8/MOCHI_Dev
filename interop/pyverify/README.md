# pyverify

An independent, read-only verifier for MOCHI archives in Python, written from the
specification and the ratification artifacts alone, sharing no code with the Rust
implementation. It is the evidence that the specification is enough to read the format:
CI runs it over every archive in `fixtures/golden/r8` and compares its verdicts with the
reference (`docs/ratification/R9-interop-results.md`).

It never writes to an archive; parity repairs are applied to an in-memory copy only.

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install --require-hashes -r interop/pyverify/requirements.txt
pip install --no-deps interop/pyverify
python3 -I -m mochi_verify ARCHIVE [--passphrase-file F] [--expected-head HEX] [--summary]
cd interop/pyverify && python -m pytest -q
```

`--summary` prints the `mochi-interop-summary-v1` JSON document; without it, a short text
report (exit 1 if the head is refused or there are findings, 3 for an operational error).
It was written in a separate session that read only `docs/spec.md`, the ratification
drafts, the CDDL schemas and the golden fixtures, never the Rust sources.
