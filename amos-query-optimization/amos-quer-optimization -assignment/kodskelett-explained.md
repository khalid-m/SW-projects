# `kodskelett.lsp` line by line

Walkthrough of the `dynprogsort` code skeleton
(`[kodskelett.lsp](kodskelett.lsp)`), matching each line against the
dynamic-programming algorithm described in
`[Ex-Query optimization in AMOS2.pdf](<Ex-Query optimization in AMOS2.pdf>)`
and the helper functions listed there. The `######` marks are the blanks the
assignment asks you to fill in — this file explains what each one needs to
become and why, without pre-filling them.


## Lisp basics primer (for readers new to Lisp)

A few small building blocks used constantly in this skeleton, explained from
scratch, before the line-by-line table below.

**Prefix notation.** Lisp writes the operator *first*, then its arguments,
all inside parentheses — where other languages write `2 + 3` (infix), Lisp
writes `(+ 2 3)` (prefix: "call `+` with inputs `2` and `3`"). Both mean 5.

**`setq` is assignment.** Where Python/JS write `x = 2 + 3`, Lisp writes:

```lisp
(setq x (+ 2 3))   ; compute (+ 2 3) -> 5, then store 5 into x
```

Lisp evaluates the *inner* parentheses first (`(+ 2 3)` → `5`), then the
outer one (`setq x 5`, i.e. "store 5 in `x`"). The `; ...` part is a
**comment** — like `//` in JS/C or `#` in Python, everything after `;` on a
line is ignored by the reader and is purely for a human to read.

**`let` declares local variables.** `(let (a b c) ...body...)` creates local
variables `a`, `b`, `c`, each initialized to `nil`, scoped to `...body...`.
This is exactly what line 7-9 of the skeleton does with `queue`, `bestplan`,
etc. — it's why they can safely be `setq`'d inside the function without
leaking into (or colliding with) global state.

**`defstruct` defines a record type**, generating a constructor and one
reader function per field automatically. Compare to a small Python class:

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

p = Point(10, 20)
print(p.x)   # 10
```

The equivalent one-liner in Lisp:

```lisp
(defstruct point x y)              ; define the "shape": a point has x and y

(setq p (make-point :x 10 :y 20))  ; create one: p is a point with x=10, y=20

(setq px (point-x p))              ; read its x field -> 10, store in px
(setq py (point-y p))              ; read its y field -> 20, store in py
```

That one `(defstruct point x y)` line automatically creates three functions:
- `make-point` — the constructor (like `Point(10, 20)`), called with keyword
  arguments (`:x 10 :y 20`).
- `point-x` — reads the `x` field back out of a point instance (like `p.x`).
- `point-y` — reads the `y` field back out (like `p.y`).

The naming rule is always `<struct-name>-<field-name>` for accessors. That's
exactly why the assignment's

```lisp
(defstruct planinfo plan bound rem cost fanout)
```

automatically gives you `make-planinfo` plus five accessors —
`planinfo-plan`, `planinfo-bound`, `planinfo-rem`, `planinfo-cost`,
`planinfo-fanout` — one per field, with zero extra code. So when the
skeleton later does:

```lisp
(setq oldplan (planinfo-plan bestplan))
```

it's doing the *exact* same thing as `(setq px (point-x p))` above, just
with a 5-field struct instead of a 2-field one: call the auto-generated
accessor `planinfo-plan` to pull the `plan` field out of the `bestplan`
struct, then `setq` stores that value into local variable `oldplan` so the
rest of the function can refer to it by that short name instead of writing
`(planinfo-plan bestplan)` again and again.

**`let` scope: assignments inside don't leak out.** A variable bound by
`let` (or declared via a proper, well-formed `let` binding list) only
exists for the duration of that `let` expression. Once it finishes, that
binding is gone — it never overwrites a same-named *global* variable
created elsewhere with `setq`. For example, a `(setq xy)` at the top level
creates/updates a **global** `xy` (defaulting to `nil` here, since no value
was given); a later, separate `let`-based use of the name `xy` operates on
its own local copy and has zero lasting effect on that global — printing
the global `xy` afterward still shows whatever the top-level `setq` last
put there. This is exactly why the skeleton's `let` (line 7-9) is where
`queue`, `bestplan`, `oldplan`, etc. live: they're scoped to `dynprogsort`'s
one call and can't collide with anything of the same name elsewhere.

**`WARNING! Setting undeclared global variable: ...`** is what ALisp prints
when you `setq` a name that was never declared first (no `let`, no
`defvar`) — it still performs the assignment (as a global), it's just
flagging that you probably meant to scope it locally instead. Harmless for
one-off debugging at the `lisp;` prompt; something `dynprogsort` itself
avoids since all its working variables are declared up front in its `let`.

**`'` (quote) means "don't evaluate this — use it literally."** Lisp
normally evaluates every sub-expression: a bare symbol like `xy` is looked
up as a variable, and `xy` written without quoting inside `(setq m xy)`
means "look up the *value* currently stored in `xy`." Prefixing a symbol
with `'`, as in `'_v2` or `'p_tournament.year->integer`, tells Lisp
"treat this as the literal symbol itself, don't look anything up" — so
`(setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 1950))`
passes the *name* `p_tournament.year->integer` to `getfunctionnamed` (which
does its own lookup by that name) and includes the literal placeholder
symbol `_v2` — not the contents of some variable called `_v2` — directly in
the resulting list.

**`list` builds a list out of its (evaluated) arguments.** Unlike `+`,
which *computes* a new value from its arguments (`(+ 2 3)` → `5`), `list`
just bundles whatever values you give it into a list, unchanged. So
`(list a b c)` evaluates `a`, `b`, and `c` individually, then returns the
3-element list `(a b c)`. This is exactly how ObjectLog predicates are
built in this skeleton: a predicate is represented as a Lisp list shaped
`(function-oid arg1 arg2 ...)`, e.g.
`(list (getfunctionnamed 'p_tournament.year->integer) '_v2 1950)` produces
`(#[OID 1001 "P_TOURNAMENT.YEAR->INTEGER"] _V2 1950)` — a function
reference followed by its arguments, bundled together as one list.

**`car` and `cdr` pull a cons cell apart.** Lisp lists are built from small
two-part boxes ("cons cells"): `car` returns the first part, `cdr` returns
the second ("rest"). Think of them as "head" and "tail":

```lisp
(car '(1 2 3))   ; => 1        (the first element)
(cdr '(1 2 3))   ; => (2 3)    (everything except the first element)
```

(The names are historical leftovers from 1950s IBM 704 hardware registers —
the acronyms no longer mean anything practical, but every Lisp dialect,
ALisp included, still uses them.)

**Dotted pairs vs. proper lists — `simple-pred-cost`'s return value.** A
dotted pair like `(28 . 1.0)` (note the `.`) holds *exactly two* values
directly — its `car` is `28`, its `cdr` is `1.0`, both plain values, not
lists. This is different from a proper list `(28 1.0)`, which is really
`(28 . (1.0 . nil))` under the hood — a chain of cons cells ending in
`nil`. The practical difference shows up in `cdr`:

```lisp
(car '(28 . 1.0))   ; => 28     a bare number
(cdr '(28 . 1.0))   ; => 1.0    ALSO a bare number (dotted pair)

(car '(28 1.0))     ; => 28     a bare number
(cdr '(28 1.0))     ; => (1.0)  a ONE-ELEMENT LIST (proper list)
```

`simple-pred-cost` returns a **dotted pair** `(cost . fanout)` — confirmed
by the real run in [`run-log.md`](run-log.md): `(28 . 1.0)`. So both halves
come out as plain numbers via `car`/`cdr`, with no extra unwrapping needed:

```lisp
(setq predcost (car (simple-pred-cost pred bpat)))    ; plain number, e.g. 28
(setq predfanout (cdr (simple-pred-cost pred bpat)))  ; plain number, e.g. 1.0
```

Had it instead returned the *list* `(28 1.0)`, `cdr` would give back
`(1.0)` — a one-element list, not the bare number — and pulling out the
fanout would need `(car (cdr ...))` (i.e. `(cadr ...)`) instead of a plain
`cdr`. The dotted-pair form is the idiomatic Lisp choice here precisely
because the function always returns exactly two related values, never a
variable-length sequence.

**`#[OID ...]` is how ALisp prints a database object reference**, not
something you type yourself. It's the same family of idea as Common Lisp's
`#<...>` unreadable-object syntax — the leading `#` signals "this is a
special printed representation, not an ordinary literal," and `[...]`
(square brackets instead of `(...)`) visually marks it as *not* a plain,
re-evaluable list. Inside, `OID 1001 "P_TOURNAMENT.YEAR->INTEGER"` is just
human-readable metadata: object ID `1001`, name
`"P_TOURNAMENT.YEAR->INTEGER"`. You get values like this back as the
*result* of calls such as `(getfunctionnamed 'p_tournament.year->integer)`,
which looks up a stored function by name and hands back this opaque
reference to it — that's what then flows into a `pred` list as its first
element.

---

| Line  | Code                                                                                                      | Explanation                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | `(setq _use_dnf_ t); make sure predicates are in disjunctive normal form before optimization!!!!`         | Sets the ALisp global flag th c e assignment calls out explicitly: the optimizer transforms predicate lists to disjunctive normal form (DNF) before calling `dynprogsort`. This is what lets `dynprogsort` assume it only ever has to reorder a flat **conjunction** of predicates, never worry about nested `OR`s itself.                                                                                                                                                                                                                                                                                                      |
| 2     | `(defun dynprogsort (l bnd)`                                                                              | Defines the function AMOS II's optimizer calls when `optmethod('exhaustive')` is set. `l` is the unoptimized `AND` predicate list (e.g. the `l1` list from the PDF: `(AND (P_MATCH.SPECTATORS->INTEGER M _V_NIL_1) ...)`); `bnd` is the list of variables already bound going in (e.g. from an outer query context).                                                                                                                                                                                                                                                                                                            |
| 3     | `;;; L is an AND predicate to be optimized.`                                                              | Comment restating what `l` is.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 4     | `;;; BND is a list of the initially bound variables in L.`                                                | Comment restating what `bnd` is — this seeds the search (a fully "free" query has `bnd = nil`).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 5     | `;;; Reorder L using dynamic programming:`                                                                | States the function's job: return `l`'s predicates in the cheapest execution order.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 6     | `(if l`                                                                                                   | Guard: if `l` is empty (no predicates — a trivial/empty conjunction), there's nothing to optimize; the function returns `nil` implicitly. Otherwise proceeds into the search.                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 7     | `(let (queue`                                                                                             | Opens a `let` to declare all local working variables. `queue` will hold the **priority queue of partial plans** (a plain list, sorted by total cost, per the PDF's "Storage structure" note — ordinary Lisp lists are fine for this exercise).                                                                                                                                                                                                                                                                                                                                                                                  |
| 8     | `bestplan oldplan oldbound oldrem oldcost oldfanout`                                                      | Locals used inside the main loop: `bestplan` is the cheapest partial plan popped this iteration; `oldplan`/`oldbound`/`oldrem`/`oldcost`/`oldfanout` are its unpacked `planinfo` fields (the plan built so far, its bound variables, its remaining unordered predicates, and its running cost/fanout).                                                                                                                                                                                                                                                                                                                          |
| 9     | `bpat predcost predfanout newplaninfo)`                                                                   | More locals: `bpat` is the binding pattern computed for a candidate next predicate; `predcost`/`predfanout` are that predicate's cost/fanout under `bpat`; `newplaninfo` is the extended `planinfo` built from appending that predicate.                                                                                                                                                                                                                                                                                                                                                                                        |
| 10    | `(setq queue ###### )`                                                                                    | **Blank 1.** Must initialize `queue` to a single-element list containing one `planinfo` with `plan = nil`, `bound = bnd`, `rem = l`'s predicate list, `cost = 0`, `fanout = 1` — the PDF's "create queue and initialize it to contain a node with cost 0 and fanout 1" (i.e. the root of the search tree in figure 2/3a, *before* picking a first predicate — note this differs slightly from the PDF prose which frames the first level as one node per predicate; seeding a single empty-plan root and letting the `dolist` below expand it on the first iteration produces the same X/Y/Z-cost nodes as the worked example). |
| 11    | `; Create queue and initialize it to contain`                                                             | Comment continuing the description for line 10.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 12    | `; a node with cost 0 and fanout 1`                                                                       | Same.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 13    | `(while t`                                                                                                | Main search loop — runs until a `return` (via the `if`/`cond` inside) exits it once a complete cheapest plan is found.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 14    | `(cond`                                                                                                   | Begin a `cond` whose first clause checks for an empty queue (an error condition), — the loop body proper follows after this `cond`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 15    | `( ######`                                                                                                | **Blank 2.** Must test "is `queue` empty?" (e.g. `(null queue)`). If the whole predicate list turns out to be unexecutable in any order, the queue eventually empties out.                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 16    | `(amos-error "Query not executable" (andify l))))`                                                        | The consequent for blank 2: if the queue is empty, no permutation of `l` was executable (e.g. some predicate had no valid binding pattern for any order), so raise an AMOS error, reporting the original conjunction via `andify` (which presumably reassembles the predicate list back into an `AND` form for the error message).                                                                                                                                                                                                                                                                                              |
| 17    | `(setq bestplan ######)`                                                                                  | **Blank 3.** Pull the **lowest total-cost** `planinfo` out of `queue`. Since the PDF requires the queue "kept sorted on total cost at all times" (so insertion — blank 8 below — does the sorting work), this is simply the first element, e.g. `(car queue)` or `(first queue)`.                                                                                                                                                                                                                                                                                                                                               |
| 18    | `(setq queue ###### )`                                                                                    | **Blank 4.** Remove `bestplan` from `queue` now that it's been popped, e.g. `(cdr queue)` / `(rest queue)` — paired with blank 3 so together they behave like a classic pop-the-min operation.                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 19    | `( ###### )`                                                                                              | **Blank 5.** The completion test: "if `bestplan` is a complete plan, return that plan." A plan is complete when it has no predicates left to order — i.e. `(planinfo-rem bestplan)` is `nil`. This should be written as something like `(if (null (planinfo-rem bestplan)) (return (planinfo-plan bestplan)))`, exploiting the PDF's monotonic-cost guarantee: because every extension of a plan can only add non-negative cost, the first complete plan popped off a cost-sorted queue is provably the cheapest one overall — the search can stop immediately rather than exhausting the rest of the queue.                    |
| 20    | `(setq oldplan (planinfo-plan bestplan))`                                                                 | Unpacks `bestplan`'s `plan` field (the ordered predicate list built so far) into `oldplan`, for convenient reuse below.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 21    | `(setq oldbound (planinfo-bound bestplan))`                                                               | Unpacks the variables already bound after executing `oldplan`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 22    | `(setq oldrem (planinfo-rem bestplan))`                                                                   | Unpacks the predicates not yet placed into `oldplan` — the ones this iteration will try to append next.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 23    | `(setq oldcost (planinfo-cost bestplan))`                                                                 | Unpacks the accumulated cost of `oldplan` so far.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| 24    | `(setq oldfanout (planinfo-fanout bestplan))`                                                             | Unpacks the accumulated fanout of `oldplan` so far — this is the multiplier used when pricing the *next* predicate (per the PDF: "the total cost so far is 100+20050=10100" — the `*50` is the previous fanout).                                                                                                                                                                                                                                                                                                                                                                                                                |
| 25    | `(dolist (pred oldrem)`                                                                                   | Iterates over every predicate still unordered in this partial plan — each one is a candidate for "what goes next," corresponding to the branching step in the PDF's search tree (e.g. from node `X`, branch to `XY` and `XZ`).                                                                                                                                                                                                                                                                                                                                                                                                  |
| 26    | `(setq bpat (bindadornpat pred oldbound))`                                                                | Computes `pred`'s binding pattern given what's already bound (`oldbound`) — i.e. which of `pred`'s arguments would be free (`+`) vs. bound (`-`) if `pred` ran right after `oldplan`. Uses the helper documented in the PDF exactly as shown there (`(bindadornpat pred bound)`).                                                                                                                                                                                                                                                                                                                                               |
| 27    | `;PRED's binding pattern`                                                                                 | Comment for line 26.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 28    | `(setq predcost ( ###### pred bpat))`                                                                     | **Blank 6.** Must call `(simple-pred-cost pred bpat)` and take its cost half — since `simple-pred-cost` returns `(cost . fanout)`, this should really be something like `(car (simple-pred-cost pred bpat))`, or the two blanks (6 and the fanout one, blank 7) might be written to share one `simple-pred-cost` call result rather than calling it twice — worth deciding when filling this in, to avoid computing the same cost model twice per candidate predicate.                                                                                                                                                          |
| 29    | `; the cost of executing PRED`                                                                            | Comment continuing description.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 30    | `; with the binding pattern`                                                                              | Comment continuing description.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 31    | `; BPAT, NIL if not executable`                                                                           | Notes the `nil` sentinel: if `pred` simply cannot run under `bpat` (e.g. no index supports that direction), `simple-pred-cost` returns `nil`, and this candidate extension must be discarded — which is exactly what the `(cond (predcost ...))` on line 32 checks for.                                                                                                                                                                                                                                                                                                                                                         |
| 32    | `(setq predfanout ( ###### pred bpat)) ; the fanout of executing`                                         | **Blank 7.** Analogous to blank 6 but for fanout — the `fo` half of `simple-pred-cost`'s `(lc . fo)` result, e.g. `(cdr (simple-pred-cost pred bpat))`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 33-34 | `; PRED with the binding` / `; pattern BPAT`                                                              | Comment continuing description of line 32.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 35    | `(cond (predcost`                                                                                         | Only proceed to build/enqueue an extended plan if `predcost` is non-`nil` — i.e. `pred` is actually executable under this binding pattern. This is the guard that discards impossible orderings instead of ever pricing them.                                                                                                                                                                                                                                                                                                                                                                                                   |
| 36    | `(setq newplaninfo`                                                                                       | Begin constructing the `planinfo` for the extended partial plan: `oldplan` with `pred` appended.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 37    | `(make-planinfo`                                                                                          | Calls the `defstruct`-generated constructor for `planinfo` (per the PDF: `(defstruct planinfo plan bound rem cost fanout)`).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| 38-41 | `:plan (append oldplan (list (substbindadorned pred bpat)))` / `; the new, extended (partial) plan`       | The new `plan` field: `oldplan` with the *concrete, binding-pattern-specific* form of `pred` appended — obtained via `substbindadorned`, which (per the PDF) "chooses the correct function (predicate) for a particular binding pattern," e.g. turning a generic `>` predicate into the physical `(CALL GT-- ...)` form once its binding pattern is known. This is the step that produces output shaped like the PDF's `l2`/`Execution plan` examples.                                                                                                                                                                          |
| 42-43 | `:bound (pred_binds pred oldbound)` / `; the variables that are bound` / `; after PRED has been executed` | The new `bound` field: the union of `oldbound` with whatever variables `pred` itself binds, via the documented `pred_binds` helper.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| 44-45 | `:rem (removeeq pred oldrem)` / `; the remaining predicates`                                              | The new `rem` field: `oldrem` minus `pred` (now placed) — `removeeq` presumably removes `pred` from the list by `eq` identity, since predicate list entries can otherwise be structurally similar.                                                                                                                                                                                                                                                                                                                                                                                                                              |
| 46-49 | `:cost ( ###### )` / `; the cost after PRED` / `; has been executed`                                      | **Blank 8 (cost).** Must compute the new running cost using the PDF's formula: `oldcost + predcost * oldfanout` — cost accumulates by the cost of the newly added predicate scaled by how many times it will be probed (once per tuple produced by everything executed so far), matching the worked example (`100+200*50=10100`).                                                                                                                                                                                                                                                                                               |
| 50-52 | `:fanout ( ###### )` / `; has been executed`                                                              | **Blank 9 (fanout).** Must compute the new running fanout: `oldfanout * predfanout` — the PDF's "fanout after executing XY is 501=50."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 53    | `))`                                                                                                      | Closes `make-planinfo` and the `setq newplaninfo` form.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| 54-56 | `(setq queue ( ###### newplaninfo queue))` / `; put extended plan into queue`                             | **Blank 10.** Must insert `newplaninfo` into `queue` **while keeping it sorted by total cost** (per the PDF: "the queue must be kept sorted on the total cost all the time"). This is likely a sorted-insert helper (e.g. something like `(insert-sorted newplaninfo queue #'planinfo-cost)`), or could fall back to appending then re-sorting the whole list with `sort`/`merge` — a design choice worth noting explicitly in the write-up, since the algorithm's correctness (always popping the true minimum in blank 3) depends on this insertion actually preserving sort order.                                           |
| 57    | `)))))))`                                                                                                 | Closing parentheses: end of `(cond (predcost ...))`, end of `(dolist ...)`, end of `(while t ...)`, end of `(let (...) ...)`, end of `(if l ...)`, end of `(defun dynprogsort ...)`.                                                                                                                                                                                                                                                                                                                                                                                                                                            |




## How the blanks map to the PDF's algorithm walkthrough

Re-reading the PDF's worked example (figure 3a–3d) against this skeleton:

- **Blank 1** (queue init) corresponds to figure 3a's starting point: `TC=0`
before any predicate has been chosen.
- **Blanks 3–5** (pop-min / remove / complete-check) are the repeated step
"the cheapest branch in the tree is now ; we remove it and add its
continuations" — done once per `while` iteration, ending the moment a
*complete* plan (all predicates placed) is popped, exactly as the PDF's
narrative stops at `YXZ` the instant it becomes the cheapest leaf.
- **Blanks 6–9** (cost/fanout of a candidate predicate, and the running
cost/fanout after appending it) are the arithmetic behind every `TC=`/`TF=`
annotation in figure 2/3 (`100+200*50=10100`, `50*1=50`, etc.).
- **Blank 10** (sorted insert) is what keeps the queue always yielding "the
cheapest branch in the tree" in blank 3 without a full re-scan/re-sort each
time — though a full re-sort would also be correct here, just less
efficient (acceptable per the PDF's note that plain lists are fine "in
this exercise").



## Caveat

This is a **structural** read of the skeleton against the documented helper
functions and cost formulas — it has not yet been verified by actually
filling in the blanks and running the result against `wc.dmp`. Per this
project's working convention (see `[../CLAUDE.md](../CLAUDE.md)` and
`[run-log.md](run-log.md)`), once `dynprogsort` is implemented it should be
loaded and traced (`(trace dynprogsort)`, `(break dynprogsort)`) against a
real query, and the actual output appended to `run-log.md` before this
explanation is treated as verified fact rather than a reading of the code
skeleton and assignment text.