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
  main (and currently only) tutorial. Walks through a small `Charstring->Number`
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
