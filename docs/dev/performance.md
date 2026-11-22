# Performance

Measured results behind the specification's cost claims (spec §27). Unless stated:
`--release` build, Rust 1.91, zstd 1.5.7 level 3, 8 MiB chunks, unencrypted, a 4 vCPU
Intel Xeon 2.1 GHz cloud VM with 15 GiB RAM, warm cache. The benchmark programs are in
`crates/mochi-testkit/examples/` (`cargo run --release -p mochi-testkit --example NAME`).
Full tables are in the git history of this file.

<a id="scaling"></a>

## Archive size and open time as history grows

Each commit writes a small delta; a full catalog (checkpoint) is written once the deltas
since the last one reach α·max(catalog size, *F*), with α = 1 and *F* = 1 MiB. Over 10,000
commits of a growing catalog (256-byte files, in memory):

| α | checkpoints | metadata | longest replay | head open | worst open |
|---:|---:|---:|---:|---:|---:|
| 1/2 | 8 | 26.9 MiB | 2,983 deltas | 351 ms | 428 ms |
| **1** | **5** | **21.2 MiB** | **4,823 deltas** | **326 ms** | **507 ms** |
| 2 | 3 | 15.0 MiB | 5,008 deltas | 423 ms | 452 ms |

Replay costs 10–60 µs per delta. The storage and replay bounds of spec B.2.3 held in every
run. α = 1, *F* = 1 MiB are the defaults (`t32_scaling`).

<a id="append"></a>

## Why checkpoints were needed

The first writer stored a full catalog with every commit: 1,000 commits holding about
4 MiB of files made a 262 MiB archive, and append time grew linearly with the catalog
(84.7 ms at 1,000 commits against 2.6 ms at 1; ext4, 1 vCPU). Delta commits with
checkpoints (above) replaced it (`c5_append_bench`).

<a id="capacity-memory"></a>

## Capacity and memory

One archive's state record is limited by the reader's default of 16 Mi CBOR items, at
49 items per single-chunk file plus 24 per extra chunk:

* about **342,391 files** of one chunk each (the binding limit);
* about 5,400 files of 1 GiB each (128 chunks).

Memory: decoding a snapshot record takes about 50 bytes per item (7.6× its stored size;
about 800 MiB at the 16 Mi item limit); opening a catalog takes 5.2–5.7× the image size (`t32_capacity`).

<a id="read"></a>

## Read path

One 73 MB archive (1,000 small files, a 64 MiB file, 200 delta commits), real file on ext4:

| step | warm | cold |
|---|---:|---:|
| find the head (footer at end of file) | 0.003 ms | 0.23 ms |
| open the catalog checkpoint | 27 ms | 27 ms |
| open the head (with 200 deltas replayed) | 42 ms | |
| read and verify a 4 KiB file | 2.7 ms | |
| read and verify the 64 MiB file | 90 ms (715 MiB/s) | |

(`c6_read_bench`)

<a id="parity"></a>

## Recovery record

Writing parity is linear in size and percentage: on a 512 MiB commit the parity step takes
0.7 s at 1 %, 3.2 s at 10 %, 21 s at 50 % and 44 s at 100 %, against 1.8 s for the commit
itself. The file grows by about the percentage, but a small commit pays at least one
16 KiB shard (a 100 KiB commit at 1–10 % grows 11 %). Checking stored bytes with a 10 %
record runs at 600–1,300 MiB/s; rebuilding damaged data runs at 100–235 MiB/s of the
protected range at 10 % (30–45 MiB/s at 50 %), and every rebuild matched the original
(`c12_parity_bench`).

<a id="threads"></a>

## Compressing on several cores

| content | 1 thread | 2 threads | 4 threads (default) |
|---|---:|---:|---:|
| one 512 MiB file | 2.29 s | 1.01 s | 0.72 s (3.2×) |
| 64 files, 512 MiB | 2.50 s | 1.42 s | 1.03 s (2.4×) |

(`c14_threads_bench`)

<a id="post-commit"></a>

## After a commit

There is no verification after a commit: the app reopens the archive to show the new
version. For a 10,000-file, 244 MiB archive: create 3.3 s; appending one file 262 ms; an
append that writes a checkpoint 955 ms; reopening 61 ms; a full `verify` from 0.6 s
(structural) to 2.1 s (restoration, the default) (`c15_postcommit_bench`).
