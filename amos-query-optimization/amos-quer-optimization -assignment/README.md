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

**Done — blanks 8 and 9** (the `:cost` and `:fanout` fields of the extended
`planinfo`, inside `make-planinfo`):

```lisp
:cost (+ oldcost (* oldfanout predcost))
:fanout (* oldfanout predfanout)
```

An earlier draft of the `:cost` line multiplied by `predfanout` (the new
predicate's own fanout) instead of `oldfanout` (the accumulated fanout of
everything executed *before* this predicate) — caught by re-checking
against the PDF's worked arithmetic: `"the total cost so far is
100+200*50=10100"`, where `200` is the new predicate's own cost and `50` is
the *previous* fanout, not the new predicate's fanout (which is `1` in that
example and never appears in the cost formula at all — it only feeds into
`:fanout`, the running total for whatever comes *after*). Conceptually:
cost is "how many times do I run this predicate," which is once per tuple
already produced upstream (`oldfanout`) — the new predicate's own output
size doesn't affect how many times *it itself* runs.

### Blank 10 — queue insert, and the design choice it forces on blanks 3/4

Two designs were considered for keeping `queue` (a plain Lisp list of
`planinfo`s) yielding "the cheapest plan" on demand — they trade work
between *insert time* (blank 10) and *pop time* (blanks 3/4), and whichever
is chosen for one **must** match the other:

**Approach A — keep `queue` sorted at insert time:**
```lisp
; blank 10:
(setq queue (sort (cons newplaninfo queue) '< :key 'planinfo-cost))
; blanks 3/4 (cheap, since queue is already sorted):
(setq bestplan (car queue))
(setq queue (cdr queue))
```

**Approach B — insert cheaply, find the minimum at pop time** (the one
`lab7.lsp` currently uses):
```lisp
; blank 10:
(setq queue (cons newplaninfo queue))
; blanks 3/4 must now search for the minimum instead of assuming (car queue):
(setq bestplan (car queue))
(dolist (p (cdr queue))
  (if (< (planinfo-cost p) (planinfo-cost bestplan))
      (setq bestplan p)))
(setq queue (removeeq bestplan queue))
```

`cons` sticks one item onto the *front* of a list without touching the
rest: `(cons 1 '(2 3))` → `(1 2 3)`. `sort` (used only in Approach A) takes
a comparison function and, via `:key`, a function to extract what to
compare by — `(sort queue '< :key 'planinfo-cost)` sorts `planinfo`
structs by their `cost` field (via the `defstruct`-generated accessor
`planinfo-cost`) rather than trying to compare whole structs directly;
both `'<` and `'planinfo-cost` are quoted since they're passed as function
*values* for `sort` to call later, not invoked immediately.

Both approaches are correct and do roughly the same total work (sorting
happens somewhere in the loop either way) — the PDF explicitly allows this
level of simplicity ("it is OK to use ordinary LISP-lists to represent a
queue" for this exercise; a real implementation would want an indexed
structure instead). **The two blanks are not independent decisions**: blank
10 being `cons`-only (Approach B) means blanks 3/4 must do the search-based
min-finding shown above (`removeeq`, not `cdr`, since the minimum may not
be at the front) — plugging Approach A's simple `(car queue)`/`(cdr queue)`
onto an unsorted queue built by Approach B's blank 10 would silently return
wrong (non-cheapest) plans.

An alternative to the manual `dolist` min-search is `(car (sort queue '<
:key 'planinfo-cost))` — reuses `sort` at pop time instead of insert time,
simpler to write but does more work than necessary (fully orders the list
just to take its first element, then discards that order immediately since
new inserts aren't kept sorted).

### Blank 1 — initializing `queue`

Filled in as:

```lisp
(setq queue (list (make-planinfo :plan nil
                                  :bound bnd
                                  :rem (cdr l)
                                  :cost 0
                                  :fanout 1)))
```

This builds the single root `planinfo` the whole search starts from — an
empty `plan`, cost `0`, fanout `1` (per the PDF: "a node with cost 0 and
fanout 1") — and wraps it in a one-element list so `queue` starts life as a
list of `planinfo`s, matching what blanks 3/4/10 all expect to operate on.

An early draft had three bugs worth documenting since each is a distinct,
generalizable Lisp mistake:

- **`(list make-planinfo :plan ...)` instead of
  `(list (make-planinfo :plan ...))`** — missing parens around the
  `make-planinfo` call itself. Without them, `make-planinfo` is a bare,
  unquoted symbol passed as one of `list`'s arguments — Lisp tries to
  evaluate it as a **variable reference** ("look up the value stored in a
  variable called `make-planinfo`") rather than calling it as a function,
  since parentheses are what make something a function call. No such
  variable exists, so this fails the same way `(setq m xy)` did earlier
  when `xy` was never assigned. The constructor call needs its own
  wrapping parens: `(list (make-planinfo :plan nil ...))`.
- **`:bound 'nil` instead of `:bound bnd`** — hardcoding an empty bound-set
  silently discards the function's own second parameter, `bnd`, which the
  doc comment explicitly defines as *"a list of the initially bound
  variables in L"*. A caller invoking `dynprogsort` with some variables
  already bound (not always empty) would have that information dropped on
  the floor. Should be `:bound bnd`.
- **`:rem l` instead of `:rem (cdr l)`** — `l` is the *entire* expression
  including its `AND` tag, shaped like `(AND pred1 pred2 pred3 ...)` (see
  the PDF's `l1` example). Setting `:rem` to `l` directly means the first
  loop iteration would treat the symbol `AND` itself as one of "the
  predicates that remain to order" — `bindadornpat`/`simple-pred-cost`
  would then be asked to compute a binding pattern and cost for the literal
  symbol `AND`, which isn't a predicate at all. `(cdr l)` strips the
  leading `AND` tag, leaving just the actual predicate list.
- (`'nil` vs. plain `nil` is not a bug — `nil` evaluates to itself either
  way — just redundant quoting.)

**Done — blanks 2, 3, 4, and 5** (all filled in, closing out the remaining
gaps in the skeleton):

```lisp
(cond
 ((null queue)                                          ; blank 2
  (amos-error "Query not executable" (andify l))))
(setq bestplan (car (sort queue '< :key 'planinfo-cost)))  ; blank 3
(setq queue (removeeq bestplan queue))                     ; blank 4
(if (null (planinfo-rem bestplan))                          ; blank 5
    (return (planinfo-plan bestplan)))
```

- **Blank 2** — `(null queue)`, guarding the "query not executable" error.
- **Blank 5** — completion check: if `bestplan` has no predicates left in
  `rem`, `return` its `plan` field as the final, cheapest answer, relying on
  the cost model's monotonicity (see the "Dynamic programming" section of
  the Linköping PDF) to guarantee correctness.
- **Blanks 3 and 4** — implement the "search-for-minimum-at-pop-time" half
  of the queue design (Approach B, paired with blank 10's plain `cons`
  insert, as laid out above): `(car (sort queue '< :key 'planinfo-cost))`
  finds the cheapest `planinfo` by fully sorting `queue` and taking the
  first element, and `(removeeq bestplan queue)` removes that specific
  element by identity (needed instead of a plain `cdr`, since — unlike a
  kept-sorted queue — the minimum isn't guaranteed to sit at the front).

  **This is correct but not efficient**, and is worth flagging explicitly:
  every single iteration of the main `while` loop **fully sorts the entire
  `queue`** (`O(n log n)`) just to read off its first element, then
  immediately discards that ordering, since new entries are inserted
  unsorted (blank 10's plain `cons`) and will need re-sorting from scratch
  next iteration too. The manual `dolist`-based min-scan discussed earlier
  in this section (`O(n)`, no full ordering computed) would do less
  redundant work for the same result — the `sort`-based version was kept
  here for simplicity/readability, which the PDF explicitly permits for
  this exercise's scale ("it is OK to use ordinary LISP-lists to represent
  a queue"), but it's not the efficient choice and shouldn't be mistaken
  for one. A real implementation, per the PDF, would want neither of
  these — "some efficient storage structure... such as an indexed tree" —
  precisely because both approaches here redo more work than necessary on
  every iteration.

All 10 blanks are now filled in `lab7.lsp`. Parenthesis balance was checked
mechanically (stripping comments first, since several comments contain
example Lisp data like `(50 . 1.78571)` that would otherwise be
miscounted as code) and confirmed to close out evenly. Next step is to
actually `(load "lab7.lsp")` inside a real `lisp;` session against `wc.dmp`
and verify it against a real query — see the plan at the end of this
section.

### Understanding `:bound` and `pred_binds`

The `:bound (pred_binds pred oldbound)` field (line 47 of `lab7.lsp`) answers
one question: *"once the predicates in `:plan` have executed, which
variables now hold a concrete value?"* This matters because the *next*
predicate's binding pattern (`bindadornpat`) is decided entirely by which
variables are already bound — that's literally how the optimizer picks `+`
(free — needs to be searched/produced) vs. `-` (bound — already known, can
be looked up) for each argument position.

Worked example, confirmed against a real `lisp;` session:

```
pred     = (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)   ; year(tournament) = _V3
oldbound = (_V3)                                                 ; year is already known (e.g. 1950)

(pred_binds pred oldbound)  =>  (_V2 _V3)
```

Reasoning: once `year(_V2) = _V3` runs with `_V3` already fixed, the result
hands back `_V2` (the specific tournament with that year) — so `_V2`
becomes newly bound, while `_V3` stays bound. `pred_binds` computes exactly
this: the union of every variable mentioned anywhere in `pred` (`_V2`,
`_V3`) with whatever was already in `oldbound` (`_V3`), giving `(_V2 _V3)`.

`pred_binds` doesn't try to reason about *which* argument became bound by
*which* mechanism — it takes the simplifying shortcut that any variable
appearing in a predicate that just executed is now bound, whether it was
already bound going in or was free and got resolved as a side effect of
running that predicate. This is valid because `bindadornpat`/
`substbindadorned` already guarantee the predicate only runs in a binding
pattern AMOS II actually knows how to execute (e.g. via an index) — so if it
ran at all, every one of its variables must now have a value.

This new `:bound` value then becomes `oldbound` on the *next* loop
iteration, when some other remaining predicate is considered — e.g.
`played_in(match)->tournament(M, _V2)` can now run with `_V2` bound (the
tournament is known), leaving `M` (the match) free — exactly the chain of
reasoning the PDF's worked `matches_in_1950` query follows
(year → tournament → match → spectators).

**Gotcha caught while testing this at the `lisp;` prompt:** `pred_binds`'s
second argument must be a proper **list**, not a bare symbol. Calling
`(pred_binds pred '_V3)` (bare atom, no parens) instead of
`(pred_binds pred '(_V3))` (one-element list) produces a malformed **dotted
list**, e.g. `(_V3 _V2 . _V3)` — the `.` right before the last element is
Lisp's way of showing "this doesn't end in `nil` like a normal list; the
final slot holds the atom `_V3` directly." This happens because `pred_binds`
conses new variables onto the front of whatever `vars` you gave it — consing
onto a proper list keeps it a proper list, but consing onto a bare atom
produces a dotted chain instead. Not a bug in `pred_binds` or in
`lab7.lsp` itself — `oldbound` is always a proper list by construction
(threaded from `bnd`, which the function's own doc comment specifies as "a
list of the initially bound variables") — just a reminder to always pass
list literals (`'(_v3)`), not bare symbols (`'_v3`), when calling
`pred_binds` interactively for debugging.

**Two more gotchas caught testing `bindadornpat` the same way** (full
transcripts in [`run-log.md`](run-log.md)):

- **Quote whole predicate literals, not just symbols.** Writing a predicate
  directly as an unquoted argument, e.g.
  `(bindadornpat (#[OID 1516 ...] _V2 _V3) '(_V3))`, makes Lisp treat the
  parenthesized list as a **function call** (unquoted parens always mean
  "call"), producing `Error 15, Undefined function: #[OID 1516 ...]`. The
  fix is the same quoting rule as `'_v2` for a single symbol, just applied
  to the whole list: `'(#[OID 1516 ...] _V2 _V3)`.
- **`bindadornpat` has no semantic awareness of what a variable means** —
  it only checks whether an argument's variable is *present* in the given
  bound-list, not whether it's the *right* variable. A hand-built
  `played_in(match)->tournament(M, _V3)` (using `_V3`, the *year* variable,
  instead of `_V2`, the *tournament* variable it should join on) still
  returned a plausible-looking `(+ -)` when tested against a bound-list
  that was mistakenly built to match. This is a general trap when unit-
  testing helper functions in isolation: it's easy to accidentally
  construct a self-consistent-but-wrong test. Always keep join variables
  named consistently with the predicate they came from (here: `_V2` for
  "the tournament," used identically in both the `year` and `played_in`
  predicates, matching the PDF's own worked ObjectLog program). A follow-up
  test confirmed extra, irrelevant bound variables in the bound-list are
  harmless (`'(_V2)` and `'(_V2 _V3)` give the same answer when the
  predicate doesn't mention `_V3`) — confirming it's always safe for
  `dynprogsort`'s real loop to pass the full accumulated `oldbound` to
  `bindadornpat`, with no need to filter it down per-predicate.

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
