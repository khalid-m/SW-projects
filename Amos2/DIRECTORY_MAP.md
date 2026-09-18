# Directory map

A guide to every top-level subdirectory of this checkout. See [CLAUDE.md](CLAUDE.md) for build/run/test
commands and a shorter architecture summary. This file goes wider: what each directory is, its key
files, what it depends on, and a rough status.

Status flags:
- 🟢 **core** — the database kernel and query processor; almost everything else depends on this.
- 🔵 **active-shaped** — a self-contained extension/project with its own install and regression
  scripts, structured like something meant to be built and run.
  ("Active" describes how it's built, not that anyone maintains it today — treat every project
  here as unmaintained unless you check its last commit.)
- ⚪ **demo/example** — sample code meant to be read or copied, not a system in itself.
  🟡 **legacy/likely-dead** — depends on very old infrastructure (JDK 1.5, Tomcat 5,
  MSVC6/BorlandC++ project files, discontinued services) or is Windows-only tooling with no
  Unix/macOS equivalent.

---

## Core

| Dir | Status | What it is |
|---|---|---|
| [system/](AmosNT_floq/system/) | 🟢 | C kernel: storage manager, buffer/index management, the aLisp interpreter, the OSQL/AmosQL grammars (bison/flex, generated into `system/C`). **The evaluator, storage, relations, indexes and plan executor are binary-only** (`.obj`/`.o`, no source); see [KERNEL.md](KERNEL.md). Platform subtrees: `Linux` (obsolete Makefile — see [CLAUDE.md](CLAUDE.md)), `Unix` (current Unix/macOS build), `MVC` (Windows/MSVC), `aix`. `system/include` and `system/C` hold shared headers/sources used by all platform builds. |
| [lsp/](AmosNT_floq/lsp/) | 🟢 | ~170 Lisp files: the AmosQL compiler, type system, and optimizer (`optimizer.lsp`; module order in `coredef.lsp`; see [QUERY_COMPILER.md](QUERY_COMPILER.md)), the ECA trigger compiler (`rule_compiler.lsp`, off by default), and `init.lsp` — the master file that loads everything and gets compiled into `bin/amos2.dmp`. Most query-language feature work happens here rather than in `system/`. |
| [C/](AmosNT_floq/C/) | 🟢 | Public C embedding API: `callin.h` (call into Amos), `callout.h` (Amos calls out to C), `storage.h`, `alisp.h`. Host applications link against `libamos.so`/`amos2.dll` using these headers. |
| [bin/](AmosNT_floq/bin/) | 🟢 | Build output + install scripts: `amos2`/`amos2.dmp` (main system), `alisp`/`alisp.dmp` (bare Lisp REPL), `libamos.so`, `bt.so`/`xt.so` extenders, `javaamos.jar`. `install.sh`/`install.bat` drive the build. |
| [regress/](AmosNT_floq/regress/) | 🟢 | Core regression suite — mostly self-contained `.osql`/`.lsp` scripts, run via `regress/Makefile`. Good source of executable AmosQL examples (`basic.lsp`, `bags.osql`, `cursor.osql`, `disjunctions.osql`, etc.). |
| [doc/](AmosNT_floq/doc/) | 🟢 | User-facing docs: `amos_users_guide.html`, `amos12_users_guide.html`/`amos13_users_guide.html`, `tut.pdf` (OO database design tutorial), `alisp.pdf`, `aStorage.pdf`, `amos-command-line.txt` (CLI flag reference). Start here for language/usage questions. |
| [headers/](AmosNT_floq/headers/) | ⚪ | Just CVS header templates for C/AmosQL/Lisp/Python/cmd files. No functional code. |
| [CVS/](AmosNT_floq/CVS/) | — | CVS metadata for the root directory itself. Not source; the whole tree still has scattered `CVS/` dirs and `$Log$`/`$Revision$` comments from this era. |

## Embedding & foreign-language interfaces

| Dir | Status | What it is |
|---|---|---|
| [demo/](AmosNT_floq/demo/) | ⚪ | Example Amos II applications: the World Cup tutorial database (`tutorial.amosql`, `wcdata.amosql`), a C client demo, a Java foreign-function demo. Read after `doc/tut.pdf`. |
| [demo10/](AmosNT_floq/demo10/) | 🟡 | Same idea as `demo/` but packaged as Visual Studio 2010 projects (`.vcxproj`). Windows-only. |
| [Java/](AmosNT_floq/Java/) | 🔵 | JavaAmos: the Java↔Amos II interface. Demonstrates Java callout functions and browsing via the Goovi multi-database browser. Large `.class` tree suggests a prebuilt/compiled distribution sits alongside the source. |
| [python/](AmosNT_floq/python/) | ⚪ | Minimal example of Amos foreign functions implemented in Python (`foreign.py`, `pythonfns.amosql`). Small and easy to read end-to-end. |
| [ODBCAmos/](AmosNT_floq/ODBCAmos/) | 🟡 | C source for an ODBC driver exposing Amos II. Points to an external PDF for docs (`cis98019.pdf`, from 1998). |
| [MPI/](AmosNT_floq/MPI/) | 🟡 | Notes on running Amos-related code under MPICH2 on Windows. Thin — mostly a readme plus a `Demo` folder. Related to `astro/` (BlueGene/MPI stream processing). |
| [extenders/](AmosNT_floq/extenders/) | 🟢/🔵 | Dynamically loaded native extension modules, loaded at runtime via `load-extension`. `BTREE` and `XTREE` (index types) are built by the core Unix Makefile and are effectively part of the core build. `Judy` is another index extender. `myAmosExtenders`/`myLispExtenders` are *template* folders showing how to write your own C extensions to AmosQL/aLisp. |
| [jarlib/](AmosNT_floq/jarlib/) | — | Drop-in folder for third-party `.jar` dependencies (MySQL JDBC driver, Swing worker, etc.) used by various Java-based subprojects. |

## Wrappers & mediation (foreign data source access)

| Dir | Status | What it is |
|---|---|---|
| [wrappers/](AmosNT_floq/wrappers/) | 🔵 | The largest directory (~1800 files). Each subfolder is a wrapper exposing an external data source as Amos foreign functions/types: `JDBC`, `ODBC`, `Mongo` (MongoDB — has its own install/run scripts and a tutorial in its readme), `RDF`/`CRDF`/`ntriples`, `BigTable`, `SparQL`, `ROOTWrap` (CERN ROOT files, used by `aleh`), `Twitter`, `TopicMap`, `WSMED`/`WSDM` (web-service-based sources), `Xtree`/`MBTree`/`trie` (index structures exposed as wrappers), `datasource`/`relational`/`amosexport`/`Amos` (generic/relational and Amos-to-Amos wrapping), `gsl`, `labview`. Treat each subfolder as an independent mini-project; most have their own `compile.cmd`. |
| [BigIntegrator/](AmosNT_floq/BigIntegrator/) | 🔵 | "Generic system to wrap external data sources having databases with different capabilities" (per its readme) — i.e. capability-based query mediation across heterogeneous sources. `src/AmosQL` and `src/Lisp` hold the mediator core (absorber and finalizer managers, access filters); `Bigtable` (App Engine) and `SparQL` are source-specific wrappers; `relational/` is an old 2012 copy, and the live relational wrapper is `wrappers/relational/`. **FLOQ** (in `regress/` and `FLOQ/`) is Minpeng Zhu's 2013–14 research on one declarative query over a MySQL metadata DB plus a collection of SQL Server log DBs, run in parallel on Amos peers. It is not in the standard image; experiment scripts load it by hand. See [BIGINTEGRATOR.md](BIGINTEGRATOR.md). |
| [SQL/](AmosNT_floq/SQL/) | 🔵 | "SQLFront" — a SQL front end layered on Amos II (installed via `compile`, tested via `(load "regress/master.lsp")`). Separate from the wrapper-level SQL access in `wrappers/`. |
| [orwise/](AmosNT_floq/orwise/) | 🔵 | Another wrapping project (`orwise.jpr` is a JBuilder project) — `make_wrappers.bat` suggests it auto-generates wrapper code. Has its own `demo/` and `initORWISE.osql`. |

## Stream processing

| Dir | Status | What it is |
|---|---|---|
| [scsq/](AmosNT_floq/scsq/) | 🔵 | SCSQ — Stream-Continuous SQL, Amos's data stream query engine. Installed like core Amos (`install.cmd` calls `bin/install.bat`) then layers stream operators on top. Large (900+ files); has its own `bench/`, `config/`, `coord.cmd`/`coord.sh` (coordinator process for distributed stream nodes). |
| [gsdm/](AmosNT_floq/gsdm/) | 🔵 | GSDM — "Extensible distributed data stream management system for scientific applications" (per `GSDMREADME` at repo root). Sits on top of SCSQ/Amos across multiple machines; needs `AMOS_HOME`/`NAMESERVER_HOST` env vars and SSH key setup for the worker nodes. `gsdm/C` has broadcaster/receiver code for UDP data streams; `gsdm/osql` has scenario scripts run via a coordinator. |
| [astro/](AmosNT_floq/astro/) | 🟡 | SCSQ ported to run on a BlueGene supercomputer over MPI (`bglpersonality.c`, `mpiamos.c`, `mpicomm.c`) for radio-astronomy (LOFAR) data. Very environment-specific; unlikely to build outside that original cluster. |
| [DEBS2013/](AmosNT_floq/DEBS2013/) | 🔵 | The team's entry to the DEBS 2013 Grand Challenge (soccer sensor-stream analytics). Self-contained: `debs.cmd`/`debs.sh` plus `q1.cmd`..`q4.cmd` to run individual queries against the "full-game" dataset (downloaded separately, per `instruction.txt` at repo root). Includes the presentation/paper (`DEBS_presentation1.pptx`, `debs307g-Badiozamany.pdf`). |
| [Vortex/](AmosNT_floq/Vortex/) | 🔵 | "Smart Vortex" project — an industrial stream-processing system (SVALI / FDSMS) built on SCSQ+Amos, with example data and regression tests for three industrial partners: `Hagglunds` (Hägglunds Drives), `Sandvik` (Coromant — proprietary CORENET protocol, per its readme), `Volvo`. Has prebuilt OSX binaries in `binOSX/`. `extensions/` shows how to write foreign SVALI functions in C. |
| [aqit/](AmosNT_floq/aqit/) | 🔵 | AQIT — per `aqit/doc/aqit.txt`, an indexing/query-rewrite layer (`ud-index-cc.lsp`, `rewrite-matrix.lsp`, `dist-based-index-rewrite.lsp`) for stream queries. `init.lsp` in `lsp/` mentions "AQIT turned on by default." Has its own `experiments/` and `simulator/`. |
| [slas/](AmosNT_floq/slas/) | 🔵 | Bulk data loading tooling — `bulkloader`, `bulkdeleter`, `bulkload_logger`, `raw`, `schema`. Likely support infrastructure for loading large sensor/scientific datasets used by the stream projects. |
| [vsq/](AmosNT_floq/vsq/) | 🔵 | VSQ — types/functions for LabView-originated "fixstreams" and visualization (`vsq.lsp`: "Type definitions and functions for (LabView) fixstreams and visualization, and VSQ-specific stream functions"). Ties stream data into a visualization front end. |
| [validate/](AmosNT_floq/validate/) | 🔵 | "Svali" validation — implements the **Linear Road** benchmark (`lr`/`lrAnswer` dirs), a standard stream-processing benchmark. Built via `compile`, run via `svali svali.dmp`. |
| [logdir/](AmosNT_floq/logdir/) | 🔵 | Turns filesystem create-events into a data stream (`filestream('c:/some/dir')`). Requires Java 7. Small, self-contained (`run.cmd`/`test.cmd`). |
| [bench/](AmosNT_floq/bench/) | ⚪ | Thin — just a `system/` subfolder, likely stream/core benchmark scripts. Worth a quick look if benchmarking is the goal, otherwise skip. |

## Semantic web / RDF / scientific data

| Dir | Status | What it is |
|---|---|---|
| [SWARD/](AmosNT_floq/SWARD/) | 🔵 | Exposes RDF **"Universal Property Views"** over back-end relational databases (per its readme). Has its own `experiment/`, `odpviewer`, `rdqlParser`, and Java classes. Requires JDK 1.5.0_11+ (regression-tested up to 1.6). |
| [sard/](AmosNT_floq/sard/) | 🔵 | A related/sibling project to SWARD (similar install instructions, same JDK requirement). Has `SARD2`/`SARD2_orig` subfolders suggesting a rewritten second version alongside the original. Large — 533 files, mostly `.amosql`/`.lsp`. |
| [SQoND/](AmosNT_floq/SQoND/) | 🔵 | SciSPARQL implementation — `doc/SciSPARQL_user_manual.pdf` is the reference. `chelonia` and `storage` subfolders suggest a custom storage backend (Chelonia is a known grid/data-management system from the same lab's ecosystem). Has `apps/`, `example/`, its own `embeddings/`. |
| [ssdm/](AmosNT_floq/ssdm/) | 🔵 | "SSDM" — small folder of **SciSPARQL example scripts** (`talk.sparql`, `talk.ttl`) meant to be run against the `ssdm` executable. Looks like the demo/tutorial counterpart to `SQoND` rather than a separate implementation — check for shared authorship before assuming they're unrelated. |
| [embeddings/](AmosNT_floq/embeddings/) | 🔵 | Front-end/client bindings for talking to Amos from other stacks: `SparQL`, `RDQL`, `JDBC`, `PHP`, `Python`, `Javascript`, `Edutella` (P2P metadata exchange, EU project from the 2000s), `wsmos` (web-service front end, includes an `XYNTService.ini` tying it to the `xynt/` Windows service). |
| [aleh/](AmosNT_floq/aleh/) | 🔵 | "Analysis of LHC Events for Higgs" — a POQSEC test-case application: C++ code to load CERN ROOT files (via `wrappers/ROOTWrap`), plus AmosQL/Lisp schema and filtering logic, to select particle-collision events matching certain conditions. Has `experiments/` and its own `simpletest.sh` regression hook (invoked from `regress/Makefile`). |
| [POQSEC/](AmosNT_floq/POQSEC/) | 🔵 | The parent project for `aleh` (POQSEC = likely "Processing Of Queries over Scientific... Collections/Compression" — name not spelled out in-tree). Contains a `generator/` plus `lsp`/`osql` sources; thin on its own, mostly scaffolding around `aleh`. |

## Web services & applications

| Dir | Status | What it is |
|---|---|---|
| [wsmed/](AmosNT_floq/wsmed/) | 🔵 | WSMED — a substantial web-service-mediation system (classes, `.amosql`, `.lsp`, own regression suite reachable via `Run regress`). Related to `wrappers/WSMED` and `wsqs/`. |
| [wsamos/](AmosNT_floq/wsamos/) | 🔵 | "A generic web service for calling Amos functions" — SOAP bindings (`WebamosService.java`, `Sward.java` ties it to SWARD) so remote clients can invoke AmosQL over a web service. |
| [wsqs/](AmosNT_floq/wsqs/) | 🟡 | Small — client-side JS/HTML (`wsqs.js`, `wsmed.html`) demoing calling WSMED from a browser, using WSDL services hosted at `user.it.uu.se/~msabesan/...`. Those external endpoints are almost certainly gone. |
| [jspAmos/](AmosNT_floq/jspAmos/) | 🟡 | JSP-based web front end (`Applications/CourseManager`, `jspTopLoop`) — a course-management demo app driven through Amos. Old JSP/servlet stack. |
| [applications/](AmosNT_floq/applications/) | 🟡 | Grab-bag of demo applications: `DataMining` (see `fpgrowth/` — FP-Growth algorithm implementation), `ExtensibleIndexes`, `grmgui`. Its readme's Tomcat 5.0.16/Jakarta setup instructions date it clearly. |
| [xynt/](AmosNT_floq/xynt/) | 🟡 | A Windows Service (`XYNTService.exe`/`.cpp`) that appears to host/proxy the web-service layer (`wsmos`, `wsqs` both reference `XYNTService.ini`). Windows-only, MSVC project files (`.dsp`/`.ncb`). |
| [oamos/](AmosNT_floq/oamos/) | ⚪ | Very thin — just a `regress/` folder and a couple of `.osql`/`.bat`/`.mdb` files. Possibly an Access/ODBC-oriented demo; not enough here to be sure without opening the files. |

---

## How to use this map

- **Core language/compiler work** → `system/` + `lsp/`, tested via `regress/`.
- **MongoDB / mediator work** (matches recent repo history) → [BIGINTEGRATOR.md](BIGINTEGRATOR.md)
  (absorber/finalizer framework, the relational wrapper as a worked example, FLOQ). Note that
  `wrappers/Mongo` here is the older C-only wrapper, not part of the optimizer.
- **Understanding a query's execution path** → [KERNEL.md](KERNEL.md) (startup, REPL, parsing,
  C↔Lisp handoff, plan execution) and [QUERY_COMPILER.md](QUERY_COMPILER.md) (flattening →
  TR → rewrite → view expansion → cost-based ordering → TBR plan).
- **Anything Windows-only** (`.cmd`/`.bat`, `.dsp`/`.vcxproj`, `xynt/`, `demo10/`) can be skipped
  if you're working on macOS/Linux, per the platform notes in [CLAUDE.md](CLAUDE.md).
- **Safe to deprioritize** (🟡 above): `astro/` (BlueGene-specific), `wsqs/` (dead external
  endpoints), `applications/` and `jspAmos/` (old Tomcat/JSP stack), `xynt/`, `ODBCAmos/`, `MPI/`.

This map was built by reading each directory's readme/install script and skimming its top-level
file layout — it hasn't been verified by building or running each subproject. Treat the "what it
is" column as a reliable summary and the status flags as a starting triage, not a final verdict.
