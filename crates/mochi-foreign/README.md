# mochi-foreign

Read-only access to ZIP, 7z, RAR 4/5, `.tar`, `.tar.gz` and `.tar.zst` for the desktop app:
list, test, and stream entries out. These formats are outside the MOCHI specification.

```
app (ForeignClient, no parser linked)  ──stdin/stdout protocol──▶  mochi-foreign-helper (child process)
                                                                   zip, sevenz-rust2, UnRAR, tar, gzip, ruzstd
```

* **All parsing happens in a separate helper process**, under limits on output, entry
  size, entry count, compression ratio, name length, time and memory. A crash, hang or
  limit breach becomes a typed error; the next call starts a fresh helper.
* **The helper never writes a file.** It streams entry bytes; MOCHI's restore engine is
  the only writer, so path-traversal, reserved-name and link protections all apply.
  Names are carried as the exact stored bytes, never normalized.
* **Results name the check that ran** ("CRC32 matched"), never MOCHI's verification words.
  tar has no per-entry check and says so.
* **RAR is read only, always.** The UnRAR source is RARLAB freeware whose license forbids
  building a RAR writer; its notice is in `THIRD-PARTY-NOTICES.md`. RAR has no
  hostile-input fixtures, because no free tool writes RAR.

Default limits: 8 GiB total output, 4 GiB per entry, 1,000,000 entries, a 200:1 ratio after
1 MiB, 65,535-byte names, 10 minutes, 2 GiB of address space (Unix). Tests use the
fixtures in `fixtures/foreign/`; fuzz targets cover each format's listing path.
