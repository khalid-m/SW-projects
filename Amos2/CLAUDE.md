# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The Amos II project lives in `AmosNT_floq/`. It is a research object-relational/functional
database system from Uppsala University's UDBL lab, plus roughly 40 research projects and
extensions built on top of it (stream processing, RDF/SPARQL mediation, data source wrappers, web
services). This checkout tracks an old CVS repository; `AmosNT_floq/readme.txt` and
`AmosNT_floq/Myreadme.txt` note it contains uncommitted distributed-database changes and predates
a merge that was never completed, so treat it as a working snapshot rather than a clean release.

All paths below are given relative to `AmosNT_floq/`, since that is the project root — `cd
AmosNT_floq` first, or prefix each path with it.

The kernel (`system/`) is written in C. The query language layer, compiler and optimizer
(`lsp/`) are written in Common Lisp ("aLisp", Amos's own embedded Lisp). Most extensions are
driven through AmosQL (`.amosql`/`.osql` scripts).

## Build

Building requires `AMOS_HOME` to point at `AmosNT_floq/`, and (Unix/macOS) `ARCHITECTURE` set to
either `Apple32` or `Linux32`:

```sh
export AMOS_HOME=/path/to/AmosNT_floq
export ARCHITECTURE=Apple32   # or Linux32
```

The canonical Unix/macOS build entry point is `system/Unix/Makefile` (NOT `system/Linux/Makefile`,
which is marked obsolete and errors out on `make`):

```sh
cd AmosNT_floq/system/Unix
make        # builds libamos.so, amos2, alisp, bt.so/xt.so extenders, amos2.dmp, alisp.dmp
make clean
```

`bin/install.sh` wraps this (`cd system/Unix && make clean && make`). The convenience scripts
`mkLinux` and `mkMac` at the `AmosNT_floq/` root do a full build and then package a distributable
zip (`amox.zip` / `MacAmos.zip`) — read them before running; they assume specific paths and delete
existing zip files unconditionally.

Build products land in `bin/`: `amos2` (main executable), `amos2.dmp` (default database image,
built by loading all of `lsp/*.lsp` and saving an image), `alisp`/`alisp.dmp` (bare Lisp REPL),
`libamos.so` (kernel), `bt.so`/`xt.so` (B-tree/X-tree index extenders built from
`extenders/BTREE` and `extenders/XTREE`).

To rebuild the database image from Lisp sources without a full recompile:

```sh
cd AmosNT_floq
bin/amos2 -i lsp   # boot from lsp/*.lsp instead of a .dmp image
```

## Running

```sh
cd AmosNT_floq
bin/amos2                      # console, loads bin/amos2.dmp
bin/amos2 -O somefile.osql     # load and execute an AmosQL script, then continue interactively
bin/amos2 -o "some osql;"      # execute an inline osql string
bin/amos2 -n nsname[:port]     # run as a nameserver (client/server setups)
bin/amos2 -s srvname[:port]@ns # run as a server registered with a nameserver
bin/amos2 -c cliname@ns        # run as a client
```

Full flag reference: `doc/amos-command-line.txt`. On Linux, `LD_LIBRARY_PATH` must include `bin/`.

## Tests

`regress/Makefile` runs the regression suite (mostly `.osql` scripts, some `.lsp`). It expects
`../bin/amos2` to already be built and needs a free nameserver port (obtained via
`bin/get_nsport.sh`):

```sh
cd AmosNT_floq/regress
make            # full suite: load, setup, test, xtree, run_java, kill, nbg, aleh, datamining, scsq, css, lr
```

To run a single `.osql` test script directly against a built binary, without the full harness:

```sh
cd AmosNT_floq/regress
../bin/amos2 -o "<'test.osql'; quit;"
```

Individual `.osql`/`.lsp` files under `regress/` are self-contained scripts, not a test-runner
framework — read one before running it to see what it asserts and whether it needs a paired
server/client setup (several targets in `regress/Makefile`, e.g. `test`, start a second `amos2`
instance with `-s`/`-n` before running the script).

Some subprojects have their own regression targets, e.g. `aleh/simpletest.sh`
(invoked as the `aleh` target above), `SQL/regress`, `slas/regress`, `validate/` (Linear Road
benchmark) — all under `AmosNT_floq/`.

## Architecture

Start at [README.md](README.md) (reading order and a list of every doc). Deep dives, written from the
source: [QUERY_COMPILER.md](QUERY_COMPILER.md) (`lsp/` compiler and optimizer pipeline),
[OPTIMIZER.md](OPTIMIZER.md) (cost model, join-ordering strategies, rewrite rules, recompilation),
[DTR_AQIT.md](DTR_AQIT.md) (late binding and inequality transformation), [STORAGE.md](STORAGE.md) (data model, updates, indexes, MEXIMA, extenders),
[KERNEL.md](KERNEL.md) (`system/` C kernel) and [BIGINTEGRATOR.md](BIGINTEGRATOR.md) (wrapper/mediator
framework, relational wrapper, FLOQ). Terms: [GLOSSARY.md](GLOSSARY.md). Generated references (rerun
the scripts in `tools/` rather than editing them): [LSP_FUNCTION_INDEX.md](LSP_FUNCTION_INDEX.md)
(every `defun`/`defmacro` in `lsp/`), [C_BUILTINS.md](C_BUILTINS.md) (every Lisp built-in registered
from `system/C`), [GRAMMAR_MAP.md](GRAMMAR_MAP.md) (AmosQL grammar rule → Lisp form → handler),
[REWRITE_RULES.md](REWRITE_RULES.md) (every rewrite-rule registration),
[AMOSQL_FUNCTIONS.md](AMOSQL_FUNCTIONS.md) (the AmosQL functions the image defines),
[C_API.md](C_API.md) (the public C API in `C/*.h`). Regenerate them all with `sh tools/regenerate.sh`. All paths below are relative
to `AmosNT_floq/`.

- **`system/`** — the C kernel. `system/C` has source for startup, the REPL, the AmosQL/SQL
  parsers (bison/flex `.y`/`.l`; generation rules in `system/Linux/Makefile`, although that
  Makefile is obsolete for building), the C↔Lisp glue, the client API, sockets and scans. **The
  aLisp evaluator, object storage, relations, indexes, B-trees, transactions and the plan executor
  (`eval`, `storage`, `rel`, `index`, `btree`, `hist`, `olog`, …) are binary-only**: `.obj`/`.o`
  in `system/MVC` and `system/Unix/Linux32`, with no `.c`. Platform subtrees: `Linux`, `Unix`
  (current canonical build, covers both Linux32 and Apple32 via `Makefile.<ARCHITECTURE>`), `MVC`
  (Windows/MSVC), `aix`. `system/include` holds the shared headers.
- **`lsp/`** — the query processor, written in Lisp: the AmosQL compiler, type system and
  optimizer. The compiler's real module list is the load order in `coredef.lsp`; the driver is
  `compile_phase2` (`comppred.lsp`) and optimization is in `optimizer.lsp`. `init.lsp` is the
  master file that loads everything into `amos2.dmp`. Most "language feature" work happens here,
  not in `system/`. (`rule_compiler.lsp` is the ECA-trigger compiler, disabled by default. It is
  not part of the optimizer.)
- `parser.y` and several other C files are ISO-8859 with CRLF line endings, so use `grep -a` or
  they are skipped as binary.
- **`C/`** — the public C embedding API (`callin.h`/`callout.h`/`storage.h`) for host applications
  that link against `libamos.so`/`amos2.dll`.
- **`extenders/`** — dynamically loaded native extension modules (index types: BTREE, Judy, XTREE)
  loaded into a running Amos image via `load-extension`.
- **Wrappers and mediation** (`wrappers/`, `BigIntegrator/`, `SQL/`, `orwise/`) — foreign data
  source wrappers (JDBC, ODBC, RDF, MongoDB, BigTable, ROOT) and query-capability-based mediation.
  `BigIntegrator/FLOQ` is one such mediator component.
- **Stream processing** (`scsq/`, `gsdm/`, `astro/`, `DEBS2013/`, `Vortex/`, `aqit/`, `slas/`,
  `vsq/`, `validate/`, `logdir/`) — SCSQ continuous/stream query extensions and distributed
  variants, including a BlueGene port (`astro/`) and the DEBS 2013 Grand Challenge entry.
  `validate/` implements the Linear Road benchmark.
- **Semantic web / RDF** (`SWARD/`, `sard/`, `SQoND/`, `ssdm/`, `embeddings/`, `aleh/`, `POQSEC/`)
  — RDF views over relational data, SciSPARQL, SPARQL/RDQL front ends. `aleh`/`POQSEC` are a CERN
  LHC event-filtering application built on Amos.
- **Language embeddings** (`Java/`, `python/`, `ODBCAmos/`, `MPI/`) — foreign function interfaces
  into and out of Amos from other languages/runtimes.
- **Web services / applications** (`wsmed/`, `wsamos/`, `wsqs/`, `jspAmos/`, `applications/`,
  `xynt/`, `oamos/`, `bench/`) — SOAP/web-service front ends and demo applications, several
  targeting old JDK/Tomcat versions.
- **`demo/`, `demo10/`** — example Amos II applications (`demo10` uses Visual Studio 2010
  project files; Windows-only).
- **`doc/`** — HTML/PDF user guides (`amos_users_guide.html`, `tut.pdf`, `alisp.pdf`,
  `amos-command-line.txt`).

Most subprojects are independent of each other and depend only on the core (`system/` + `lsp/`
+ `bin/amos2`) plus, for many of them, Java (`Java/`, JDBC-based wrappers) or a JDK-era web
stack (Tomcat, older JDKs) that may no longer be current.

## Platform notes

- Much of the tree (build scripts ending `.cmd`/`.bat`, `.dsp`/`.dsw`/`.vcxproj` project files,
  `.dll`) targets Windows/MSVC and is not relevant when developing on macOS/Linux.
- The Unix/macOS build forces `-m32` (32-bit) compilation in `system/Unix/Makefile` — verify your
  toolchain supports 32-bit builds before debugging build failures that look unrelated to your
  change.
- CVS (not git) was the original VCS; `CVS/` metadata directories and `$Log$`/`$Revision$` headers
  throughout the source are leftovers from that history, not something to maintain going forward.
