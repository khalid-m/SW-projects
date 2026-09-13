# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This is a standalone knowledge base of runnable tutorials on **AMOS II query
optimization and indexing** — specifically, how to read AMOS II's physical execution
plans (`pc(...)` output) and how different index types (`hash`, `mbtree`, and any
others explored later) behave under different query binding patterns.

It originated from working through a university database systems assignment on
extensible indexing in AMOS II, but is deliberately kept independent of that
assignment's specific code/dataset — this repo is a general-purpose reference for
AMOS II's query planner, not a copy of any coursework. Content here should stand on
its own for anyone learning AMOS II's optimizer, regardless of what assignment (if
any) prompted the exploration.

## Repository contents

- [`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md) — the
  index/execution-plan tutorial. Walks through a small `Charstring->Number`
  stored function (`asci_map`) and a `Person` type with `dept`/`age` attributes,
  building up:
  1. `HASH-INDEX-GET` — unique-key forward lookup.
  2. `HASH-FULL-SCAN` — reverse-direction lookup through the same hash index, with
     no index on the result side.
  3. `HASH-INDEX-SCAN` — a `"multiple"` (non-unique) hash index, and how a single
     stored function can carry two independent per-parameter-position indexes.
  4. `MBTREE-INDEX-SCAN` — an ordered index type that supports equality lookups
     like a multi-value hash index, but (on the AMOS II release tested) does **not**
     support `>`/`<` range predicates out of the box.

- [`lisp-foreign-functions.md`](lisp-foreign-functions.md) — how to implement an
  AmosQL function in ALisp (the `callout` interface) and call AmosQL back from
  Lisp (`callin`). Protocol, `osql-result`, multi-directional declarations, the
  `osql`/`AMOS_` embedded-query interface, and the traps: built-in name
  shadowing, coercion warnings, generic vs. resolvent function objects. Needs no
  compiler or driver program, which makes it the practical route for extending
  the system in this environment.

- [`cost-based-vs-rule-based-optimization.md`](cost-based-vs-rule-based-optimization.md)
  — AMOS II's cost-based optimizer compared with Polars' rule-based lazy
  optimizer: where each gets its estimates, and where each breaks down.

- [`query-rewrite/`](query-rewrite/) — TBR-rewrite rules, the mechanism that lets
  the optimizer turn ordinary predicates into calls to specialised access
  routines.
  - [`rewrite.txt`](query-rewrite/rewrite.txt) — the official AMOS II document.
  - [`README.md`](query-rewrite/README.md) — notes on it, plus the resolved
    investigation into **why `mbtree` range access fails on this build**: the
    rewrite rule is present and fires, but `MBT-SELECT-RANGE`'s generic function
    carries no implementation. Includes the `optmethod` A/B that pins the failure
    to the rewrite path rather than the index.
  - [`building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md) — a
    rewrite rule and its Lisp access routine built from nothing, one verified
    step at a time, ending with three predicates collapsed into a single `CALL`.

## Reference material

Official AMOS II documentation is kept locally as a sibling directory,
[`../Amos-II-docs/`](../Amos-II-docs/) (source:
https://www.it.uu.se/research/group/udbl/amos/), containing:

- `intro.amosql.txt` — introductory tutorial (AmosQL script).
- `Amos II Release 18 User's Manual.html` — the full user's manual.
- `tut.pdf` — tutorial on object-oriented data modeling with Amos II.
- `Amos II cheat sheet.html` — quick syntax/function reference.
- `FuncMedPaper.pdf` — "Functional Data Integration in a Distributed Mediator
  System," the paper describing the underlying system architecture.
- `javaapi.pdf` — "Amos II Java Interfaces" (D. Elin and T. Risch), documenting the
  `callin`/`callout` Java foreign-function API (`CallContext`, `Tuple`, etc.) used
  to implement foreign functions like the ones this repo's tutorial calls.
- `external.pdf` — "Amos II External Interfaces" (T. Risch). The reference for
  binding non-AmosQL implementations into the query engine. **§3.2 and §3.2.1
  cover the ALisp callout interface** — the only foreign-function route that
  needs no compiler — and §2.2 the ALisp callin interface. Note that its code
  examples contain errors (its `sqrt2` references an unbound variable); trust the
  prose over the snippets.
- `alisp.pdf` — the ALisp interpreter manual. **Despite the name, this is not the
  document for writing AmosQL functions in Lisp** — its "foreign function"
  chapter covers the opposite direction, C functions callable *from* ALisp. Use
  `external.pdf` §3.2 instead.

Consult these before assuming AMOS II syntax or behavior — but per the working
convention below, still verify against a real `Javaamos`/`amos2` run before writing
anything into this repo's tutorials as fact, since documented behavior and a
specific release's actual behavior have already diverged once (`"btree"` vs.
`"mbtree"` as a valid index-type name).

## Working conventions for this repo

- **Every claim about AMOS II behavior in the tutorial must be backed by an actual
  run's output**, not assumed from documentation or general database theory —
  several sections were corrected after real output contradicted an initial guess
  (e.g. `"btree"` is not a valid index-type name on the tested release, only
  `"mbtree"` is; `mbtree` supports `=` but not `>`/`<`). When extending this
  tutorial or adding new ones, run the AmosQL first and paste the real transcript
  before writing the explanation.
- **`pc("<functionname>")` shows that function's own default/forward binding
  pattern** (whatever arguments were declared as inputs when the function was
  created), not the plan for some other query that merely calls it. To inspect the
  plan for a *specific* binding direction (e.g. a reverse lookup), wrap that exact
  query in a new named function first, then `pc()` that function. This gotcha
  recurs throughout the tutorial and is worth restating in any new material.
- A stored function's result parameter must be **named** (e.g. `-> Charstring d`,
  not just `-> Charstring`) before `create_index` can refer to it by that name.
- Plan operators follow a `<STRUCTURE>-<OPERATION>` naming convention (e.g.
  `HASH-FULL-SCAN`, `MBTREE-INDEX-SCAN`): the structure names the physical index
  being read, the operation names how it's traversed. A stored function's tuples
  live *inside* whatever index structure was built on it — there's no separate
  generic "table" storage underneath.
- No build/test tooling here — this is documentation only. There's no code to run
  outside of an actual AMOS II (`Javaamos`/`amos2`) session, which isn't part of
  this repo.
