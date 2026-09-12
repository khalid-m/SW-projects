# Assignment 7 — Query optimization in AMOS II

Course materials for the actual assignment this repo's tutorials grew out of
(kept here per [`../CLAUDE.md`](../CLAUDE.md) as source material, independent
of the general-purpose tutorial content one level up).

## What's in this folder

- [`Database Technology II_ Assignment 7 - Query optimization in Amos II.pdf`](<Database Technology II_ Assignment 7 - Query optimization in Amos II.pdf>) —
  the assignment as actually issued (Örebro University, Thomas Padron-McCarthy,
  2012). This is the authoritative task description; it wraps the older
  Linköping lab below and tells you what to ignore in it.
- [`Ex-Query optimization in AMOS2.pdf`](<Ex-Query optimization in AMOS2.pdf>) —
  the original Linköping "PC lab" instruction (Exercise 7) that the Örebro
  assignment builds on. Contains the actual explanation of AMOS II's cost
  model and the dynamic-programming search algorithm.
- [`kodskelett.lsp`](kodskelett.lsp) — the real code skeleton for the
  `dynprogsort` Lisp function, with `######` marking the blanks to fill in.
- [`wcdata.amosql`](wcdata.amosql) — AmosQL data/schema for the World Cup
  ("soccer") example database (`match`, `tournament`, etc.) used to exercise
  the optimizer.

## The task, in short

Write an ALisp function `dynprogsort` that takes an unoptimized conjunction
of ObjectLog predicates (already in disjunctive normal form) and returns the
cheapest permutation — i.e. implement AMOS II's exhaustive query optimizer,
which the stock build only stubs out. `optmethod('exhaustive')` tells the
regular optimizer to delegate to `dynprogsort` once it's loaded.

Two documents disagree on some incidental details — **follow the Örebro PDF's
"ignore obsolete things" note** (e.g. where `kodskelett.lsp` is said to live,
and which AMOS II binary/dump to run) rather than the older Linköping text
where they conflict:

- Use the **older AMOS II build from Assignment 4**, not whatever the
  Linköping PDF references.
- Replace `amos2.dmp` with the `amos.dmp` linked from the Örebro assignment
  before Lisp debugging (`break`, `trace`, etc.) will work correctly.
- Groups of 1–2 (occasionally 3, with instructor sign-off); collaboration
  across groups is fine but each group reports and hands in separately.

## The algorithm (from the Linköping lab)

AMOS II's cost model gives each predicate, under a given binding pattern, an
estimated **cost** (`2 × tuples visited`) and **fanout** (result size). The
search is a branch-and-bound / dynamic-programming exploration of predicate
orderings:

1. Seed a priority queue with one partial plan per predicate (cost = that
   predicate's standalone cost, fanout = its standalone fanout).
2. Repeatedly pop the **lowest total-cost** partial plan from the queue.
   - If it has no remaining predicates, it's a complete plan — **return it**.
     Cost grows monotonically as predicates are appended, so the first
     complete plan popped is guaranteed cheapest; the search can stop there
     without exploring the rest of the queue.
   - Otherwise, extend it by appending each still-remaining predicate,
     computing that predicate's binding pattern (`bindadornpat`), cost and
     fanout at that binding (`simple-pred-cost`), and pushing each resulting
     partial plan back into the queue with:
     - `cost' = cost + predicate_cost × fanout`
     - `fanout' = fanout × predicate_fanout`

The worked example in the Linköping PDF (predicates `X`, `Y`, `Z`) walks this
to completion and finds `YXZ` (total cost 700) cheapest among all 6
permutations, without the search ever having to expand every branch of the
full tree.

## Key ALisp building blocks

| Function | Purpose |
|---|---|
| `simple-pred-cost pred bpat` | `(cost . fanout)` for `pred` under binding pattern `bpat`, or `nil` if not executable that way |
| `bindadornpat pred bound` | binding pattern (`+`/`-` per argument) for `pred` given which variables in `bound` are already bound |
| `substbindadorned pred bpat` | picks the concrete predicate/function for a given binding pattern |
| `pred_binds pred vars` | union of `vars` with the variables `pred` binds |
| `planinfo` struct (`plan bound rem cost fanout`) | one queue entry: partial plan so far, its bound variables, remaining predicates, running cost/fanout |

Debugging: `(objlog "<query>;")` dumps a query's unoptimized/optimized
ObjectLog form; `(break dynprogsort)` / `(trace dynprogsort)` instrument the
function during a `lisp;` session; `(load "lab7.lsp")` reloads edits.

## `pc()` output: older build vs. newer build

Two AMOS II builds were both run for this assignment (see
[`run-log.md`](run-log.md) for the full transcripts) — an older one (per the
Örebro assignment's "use the version from Assignment 4" instruction) and a
newer one also available on the lab VM:

| | Older build | Newer build |
|---|---|---|
| Path | `older-amos2\bin\amos2` | `AmosNT_floq\bin\amos2` |
| Version banner | `Amos II Release 8, v2` | `Release 16, v11` |
| Prompt | `Amos n>` | `AmosQL n>` |

Running `pc("matches_in_1950")` against the **same** stored function on each
produces very different output.

**Older build** (Release 8, v2) prints a sequence of optimizer *stages* as
flat ObjectLog predicate lists — no physical operators named anywhere:

```
Original definition of MATCHES_IN_1950->MATCH: ...
Simplified: ...
Normalized and simplified: ...
Coerced: same
Decomposed (TBR):
(MATCHES_IN_1950->MATCH M+) <-
(AND (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
     (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
     (P_MATCH.SPECTATORS->INTEGER M _V2)
     (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V2 100000))
```

The final "Decomposed (TBR)" stage is the closest thing to a plan, but it
only shows the chosen *predicate order* and binding pattern — it never names
an index-access method.

**Newer build** (Release 16, v11) instead prints a single, much more
informative **"Execution plan"** section, expressed directly in terms of
physical operators:

```
Execution plan:
(MATCHES_IN_1950->MATCH M+) <-
(NESTED-LOOP-JOIN
   (HASH-FULL-SCAN #[OID 1515 "TOURNAMENT.YEAR->INTEGER"] _V3+ 1950)
   (HASH-FULL-SCAN #[OID 1549 "MATCH.PLAYED_IN->TOURNAMENT"] M+ _V3-)
   (HASH-INDEX-GET #[OID 1552 "MATCH.SPECTATORS->INTEGER"] M- _V2+)
   (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] _V2- 100000))
```

This is exactly the `<STRUCTURE>-<OPERATION>` naming convention documented
in [`../tutorial-index-execution-plans.md`](../tutorial-index-execution-plans.md)
(`HASH-FULL-SCAN`, `HASH-INDEX-GET`, etc.) — the older build simply doesn't
surface that information through `pc()` at all.

Despite the very different presentation, **both builds agree on the
underlying optimizer decision**: predicate order `year → played_in →
spectators → GT--` (the `>` test) in both cases — same plan, different
report format.

**Practical implication:** when producing or verifying execution-plan output
for the tutorial or the Exercise 7 report, run `pc()` on the **newer build**
(`AmosNT_floq`) — its output is what the tutorial's index-execution-plan
material assumes. The older build is still needed for the `dynprogsort`
Lisp work itself, since the Örebro assignment specifies that version for
ALisp/`optmethod('exhaustive')`.

## Writing `lab7.lsp`

[`lab7.lsp`](lab7.lsp) is the working copy of the skeleton — a straight copy
of [`kodskelett.lsp`](kodskelett.lsp), with the 10 `######` blanks being
filled in one at a time. See
[`kodskelett-explained.md`](kodskelett-explained.md) for a full line-by-line
walkthrough of the skeleton (including a Lisp basics primer) and what each
blank needs to become.

### Progress so far

**Done — blanks 6 and 7** (the cost/fanout of a candidate predicate, inside
the `dolist` loop over remaining predicates):

```lisp
(setq predcost-fanout (simple-pred-cost pred bpat))
(setq predcost (car predcost-fanout))
(setq predfanout (cdr predcost-fanout))
```

Rather than calling `simple-pred-cost` twice (once for the cost, once for
the fanout — the two separate blanks as originally laid out in the
skeleton), this calls it **once**, storing the full `(cost . fanout)` dotted
pair in a new local `predcost-fanout`, then splits it with `car`/`cdr`.
Two things had to be fixed to make this work correctly, both good general
Lisp lessons (see [`kodskelett-explained.md`](kodskelett-explained.md) for
the underlying concepts of `let` scoping and dotted pairs):

- `predcost-fanout` had to be **added to the `let` binding list** (the big
  list of local variable names right after `(let (queue ...`). Any `setq`
  onto a name not declared there is treated as an implicit *global*
  assignment by ALisp, printing `WARNING! Setting undeclared global
  variable: ...` — harmless for one-off debugging at the `lisp;` prompt (see
  the real example of this warning in [`run-log.md`](run-log.md)), but wrong
  inside a function meant to be re-entrant and side-effect-free between
  calls.
- Both `setq` forms needed **matching closing parens**. An initial draft
  left `(setq predcost (car predcost-fanout)` and
  `(setq predfanout (cdr predcost-fanout)` each missing their final `)` —
  which doesn't error immediately, but silently causes the Lisp reader to
  keep consuming the *next* form (the second `setq`, then the `cond`
  guarding `make-planinfo`, and so on) as extra arguments to the first,
  still-open `setq`. This is the kind of bug that's easy to introduce and
  hard to notice by eye in deeply-nested Lisp — worth double-checking paren
  balance around every edited blank.

**Still open:**

- **Blank 1** — initialize `queue` to a single-element list holding one
  `planinfo` with an empty `plan`, `bound = bnd`, `rem` = `l`'s predicate
  list (i.e. `(cdr l)`, stripping the leading `AND`), `cost = 0`,
  `fanout = 1`.
- **Blank 2** — the empty-queue test (`(null queue)`) guarding the
  "query not executable" error.
- **Blanks 3 and 4** — pop the lowest-total-cost `planinfo` off the front of
  `queue` (`(car queue)`) and remove it (`(cdr queue)`) — valid only because
  blank 10 (below) keeps `queue` sorted by cost on every insert.
- **Blank 5** — the completion check: if `(planinfo-rem bestplan)` is empty,
  `return` `(planinfo-plan bestplan)` as the final answer, relying on the
  cost model's monotonicity (see the "Dynamic programming" section of the
  Linköping PDF) to guarantee this is the cheapest plan overall.
- **Blanks 8 and 9** — the new `:cost` and `:fanout` fields for the extended
  `planinfo`: `oldcost + predcost * oldfanout` and
  `oldfanout * predfanout`, per the PDF's worked example arithmetic
  (`100+200*50=10100`, `50*1=50`).
- **Blank 10** — insert the newly built `planinfo` into `queue` while
  keeping it sorted by total cost (a sorted-insert helper, or an append
  followed by a full re-sort — the PDF explicitly allows plain lists and a
  simple approach "in this exercise").

Once all 10 are filled in, the plan is to `(load "lab7.lsp")` inside a real
`lisp;` session against `wc.dmp`, `(trace dynprogsort)` it, run
`optmethod('exhaustive')`, and confirm the output against a query with a
known-cheapest plan — then append that transcript to
[`run-log.md`](run-log.md) per this repo's verify-against-a-real-run
convention.

## Deliverable

The filled-in `dynprogsort` definition, plus example optimized queries
against the World Cup database (`wcdata.amosql`) and a trace/search path the
grader can rerun to verify the algorithm.
