# The query compiler and optimizer (`lsp/`)

How Amos II turns an AmosQL query into an execution plan, traced through the Lisp source in
[AmosNT_floq/lsp/](AmosNT_floq/lsp/). Companion to [KERNEL.md](KERNEL.md), which covers the C side:
how a query arrives, and what runs the finished plan.

Your notes in [../amos-query-optimization/](../amos-query-optimization/) describe the optimizer from
the outside (`pc()` transcripts, REPL introspection, the 1992 paper). This file describes it from the
source. Line numbers refer to this checkout. Code excerpts are quoted, sometimes trimmed. Anything
that is inferred rather than read is marked as such. Nothing here was executed: there is no working
build in this checkout (see [KERNEL.md](KERNEL.md)).

---

## 1. The pipeline at a glance

```
"select name(host(t)) from Tournament t where year(t)=y;"
        │  C parser (system/C/parser.y), called from the REPL or parse-file   ── C ──
        ▼
(OSQL-SELECT (...) FOREACH (...) WHERE (...))      a Lisp S-expression
        │  evalfn → macro osql-select → map-select → generate-select        fncall.lsp
        ▼
createsimplederivedfunction   the query becomes an (anonymous) derived function
        │
compileselect                 flatten nested calls + resolve overloads + type checks
        │                     function.lsp:733, flatten.lsp, typecheck.lsp
        ▼
compile_phase2                comppred.lsp:162
   compilepredicate           → TR predicate  (logical ObjectLog)
   rewrite                    equality unification, TR rewrite rules, partial evaluation
   expand-predicate           view expansion (inline derived functions)
   rewrite
   aqit-fixpoint              AQIT (on in the standard image)
   transformpredicate         normalize to DNF
   rewrite
   optimize-pred              comppred.lsp:292
      coerce_expand + rewrite
      decompose-pred          optimizer.lsp:499
         absorber-rewrite     push predicates into wrapped sources   (BigIntegrator)
         optimize-compound-predicate → psort → ranksort | dynprogsort | random-opt
            per step: rewrite-preds → bestmodefunction → substbindadorned
         finalize             wrappers translate absorbed filters, then RE-OPTIMIZE
        ▼
selectbody-optpred            → TBR predicate  (physical plan: ordered (call impl fn args…))
        │  mapfunction / a_mapfunctionC  (binary-only C, see KERNEL.md)          ── C ──
        ▼
result tuples
```

Four ideas carry the whole design:

1. **A query is a function.** `generate-select` compiles an ad hoc query into the transient function
   `_select_`, using the same code path as `create function … as select …`. Views, derived
   functions and queries are one mechanism.
2. **The plan is a predicate, not an operator tree.** Every stage is a Datalog-like conjunction of
   calls (ObjectLog). Optimization rewrites that list in place, from *TR* form (which function) to
   *TBR* form (which implementation, in which order).
3. **Choosing access methods and ordering joins happen together.** The greedy loop that orders the
   predicates asks, at each step, which implementation of each candidate is cheapest *given what is
   already bound*.
4. **Plans are specialized per binding pattern.** A derived function gets a separately optimized plan
   for every input/output pattern it is called with, compiled lazily and cached.

---

## 2. Module map: where the compiler is defined

`init.lsp` is not where the compiler's structure is defined. There are three layers:

| File | Role |
|---|---|
| [init.lsp](AmosNT_floq/lsp/init.lsp) | Builds the full image: loads `amosdef.lsp` (line 170), then add-ons: multicast, ECA rules if enabled, the BigIntegrator mediator, wrappers, the SQL front end, and MEXIMA/AQIT (lines 205–216). |
| [amosdef.lsp](AmosNT_floq/lsp/amosdef.lsp) | "Fully runnable" system: loads `coredef.lsp` (line 98), then the standard library (tuples, vectors, system functions, streams, group-by, …). Defines `load-amosql` (line 109). |
| [coredef.lsp](AmosNT_floq/lsp/coredef.lsp) | **The compiler itself.** Its load order (lines 218–288) is the module map below. |

Compiler modules in `coredef.lsp` load order:

| Module | What it contributes to compilation |
|---|---|
| `function.lsp` | The `selectbody` struct, `createsimplederivedfunction`, `compileselect` |
| `foreign.lsp` | Foreign (C/Lisp-implemented) functions |
| `typecheck.lsp` | Type lattice, resolvent table, overload resolution (`resolveargs` :632, `get-most-specific-resolvent` :657) |
| `variable.lsp`, `predicate_functions.lsp`, `environment.lsp` | Variable and binding bookkeeping during compilation |
| `flatten.lsp` | Flattening nested expressions into flat calls; drives overload resolution |
| `latebind.lsp` | Late binding: calls whose resolvent must be chosen at run time (DTR) |
| `comppred.lsp` | **`compile_phase2`, the pipeline driver**; TR generation; view expansion |
| `recompile.lsp` | Recompiling dependents when a function changes |
| `optimizer.lsp` | **Cost-based optimization**: cost model, ranking, access-method choice, TR→TBR |
| `olog.lsp` | Small helpers to run a plan directly (`map-plan`, `plan-tuples`) |
| `subplan.lsp`, `purge.lsp` | Sub-plans; `purge-void-preds` (replace unused variables by `*`) |
| `rewrite.lsp` | TR-level rewriting: equality unification, TR rewrite rules, OR→IN |
| `TBR.lsp`, `DTR.lsp` | The `tbr` struct: per-binding-pattern implementations, cost hints, TBR rewriters; late-binding types |
| `priority-queue.lsp`, `dynprog.lsp`, `randomopt.lsp` | Alternative join-ordering strategies |
| `normalize.lsp` | DNF normalization |
| `proc.lsp`, `fncall.lsp` | Entry points: `osql-select`, `map-select`, `generate-select`, `prepare-query`, `amos-execute` |
| `BigIntegrator/src/Lisp/absorbmng.lsp`, `finalizermng.lsp` | Mediator hooks around the optimizer (loaded from [BigIntegrator/](AmosNT_floq/BigIntegrator/), line 254) |
| `scan.lsp` | Cursors/scans over results |
| `qd.lsp` + `qd_*.lsp` | Legacy multi-database decomposition (only reachable when DTR is off, see §9) |

---

## 3. The central data structure: `selectbody`

[function.lsp:267](AmosNT_floq/lsp/function.lsp#L267). "A SELECTBODY is a structure containing a
compiled AMOSQL function for a given binding pattern."

```lisp
(defstruct selectbody
  argl resl        ; argument / result variables
  pred             ; re-written predicate            ← TR form, kept for re-optimization
  optpred          ; optimized selection predicate   ← TBR form: the plan
  delpred          ; update template (NIL if not updatable)
  locals orgpred   ; local variables; predicate before view expansion
  argt rest loct   ; types of args / results / locals
  unoptimized expanded expanded-simplified aqit
  normalized normalized-simplified               ; intermediate stages
  coercedpred absorbed parallelized decomptree)
```

Two points are easy to miss:

- **Most stage fields are empty by default.** `unoptimized`, `expanded`, `expanded-simplified`,
  `aqit` and `normalized` are filled only when `_save-intermediates_` is true, and it defaults to `nil`
  ([comppred.lsp:130](AmosNT_floq/lsp/comppred.lsp#L130)). What is always kept: `orgpred` (used when
  *this* function is inlined into another), `pred` (the normalized TR form), `optpred` (the plan),
  and, from `decompose-pred`, `coercedpred` and `absorbed`.
- **`pred` is the input for every other binding pattern.** `bpat-optimize-function`
  ([TBR.lsp:314](AmosNT_floq/lsp/TBR.lsp#L314)) copies the selectbody, swaps which variables count as
  arguments and which as results, and re-runs `optimize-pred` on the stored `pred`. Only the steps
  from optimization onward are re-run.

The two other structs used during optimization:

- **`tbr`** ([TBR.lsp:95](AmosNT_floq/lsp/TBR.lsp#L95)): `bpat`, `selbody`, `impl`, `cost`,
  `rewriter`, `fno`. One per (function, binding pattern). It holds either a compiled selectbody (for
  derived functions) or an `impl` (for foreign functions), plus an optional cost hint and a list of
  TBR rewriters. Stored on the function object under the property `bindings`, and walked with the
  macro `mapbpats`.
- **`rewrite`** ([optimizer.lsp:442](AmosNT_floq/lsp/optimizer.lsp#L442)): scratch record for one
  optimization step: `this` (the predicate being placed), `bpat`, `bnd` (bound after it), `rest` (the
  predicates still to place), `translated` (its TBR form).

### Binding-pattern notation

A binding pattern has one symbol per argument and result position. **`-` means bound (known input)
and `+` means free (produced output).** This is the reverse of what you might guess. The code settles
it: `bpat-of-key` marks constants as `-` ([TBR.lsp:285](AmosNT_floq/lsp/TBR.lsp#L285)), and
`fanout-foreign` treats an all-`-` pattern as a pure test with a selectivity
([optimizer.lsp:1144](AmosNT_floq/lsp/optimizer.lsp#L1144)).

---

## 4. Stage by stage

### 4.1 From parsed statement to derived function

The C parser returns a Lisp form. The comment in the source shows the shape
([fncall.lsp:347](AmosNT_floq/lsp/fncall.lsp#L347)):

```lisp
;;; (parse "select a,b,c from tpe x, tpe y where x=2 and y<5 and foo(a);")
;;; (OSQL-SELECT (A B C)
;;;      FOREACH ((TPE X) (TPE Y))
;;;      WHERE (AND (AND (= X 2) (< Y 5)) (FOO A)))
```

`osql-select` is a **macro**. Evaluating the form expands it according to context:

| Context | Expansion | Result |
|---|---|---|
| Top level (REPL, `.osql` file) | `compile-printselect` (:462) | streams and prints tuples |
| Inside ALisp (`*within-lisp*`) | `compile-callselect` (:1108) | collects a list |
| Inside a stored procedure | `compile-procselect` (:854) | calls an action per row |

All three reach `osql-mapselect` → `osql-mapselectexpand`
([fncall.lsp:682](AmosNT_floq/lsp/fncall.lsp#L682)), which uses shortcuts where it can:

- **Trivial**: no `from`/`where`, only constants. It just calls the action.
- **Single call** to an existing function with constant arguments (`osql-callp`). It invokes that
  function's **pre-optimized** plan and compiles nothing new.
- **Otherwise**: `map-select` ([fncall.lsp:1122](AmosNT_floq/lsp/fncall.lsp#L1122)) →
  `generate-select` (:577), then runs the result with `mapfunctionres`.

```lisp
(defun generate-select (resl quant pred &optional fno)
  "Generate query plan on the fly"
  (resetgenvar
   (let ((quant (substdeclarations quant))
         (fno (or fno _select_)))
     (createsimplederivedfunction fno nil nil resl quant pred t)
     (set-orgcode fno nil nil resl quant pred)
     fno)))
```

`_select_` is one reusable transient function, documented as "The latest ad hoc query plan"
([optimizer.lsp:393](AmosNT_floq/lsp/optimizer.lsp#L393)). Each new ad hoc query overwrites it. The
programmatic entry points `compile-query`/`prepare-query`
([fncall.lsp:513,528](AmosNT_floq/lsp/fncall.lsp#L513)) take a query *string*, parse it, and
reach the same `createsimplederivedfunction` ([function.lsp:712](AmosNT_floq/lsp/function.lsp#L712)).
That function makes an empty `selectbody`, calls `compileselect`, and caches a cost.

### 4.2 Flattening, overload resolution and type checks: `compileselect`

[function.lsp:733](AmosNT_floq/lsp/function.lsp#L733), "First part of the query compilation:
flattening and typechecks".

- `flattenpredicate` (called at :764; defined [flatten.lsp:763](AmosNT_floq/lsp/flatten.lsp#L763))
  flattens the `where` clause. `flattenarglist` (:769) does the same for the `select` list.
  Flattening turns `name(host(t))` into a chain of flat calls joined by fresh variables, much like
  three-address code.
- **Overload resolution happens during flattening, not as a separate pass.** `flattenfuncall`
  ([flatten.lsp:341](AmosNT_floq/lsp/flatten.lsp#L341)) flattens the arguments first, so their
  types are known, then either:
  - calls `resolveargs` ([typecheck.lsp:632](AmosNT_floq/lsp/typecheck.lsp#L632)) to pick the most
    specific resolvent, e.g. `name(Person)` versus `name(Country)`; or
  - if `_USE_DTR_` is on (the default, [coredef.lsp:124](AmosNT_floq/lsp/coredef.lsp#L124)) and the
    types can't be settled statically, emits a **late-binding** DTR call (`flattenlatebinding`).

  It also recompiles stale callees (`needs-recomp?` → `recompile_depend`), handles nested
  `select`s, casts, and coercion to bags.
- `gen_typechecks` (called at :787, defined :798) adds type-check predicates for the
  declared variables.
- It then hands over to `compile_phase2` (:796).

### 4.3 The driver: `compile_phase2`

[comppred.lsp:162](AmosNT_floq/lsp/comppred.lsp#L162), "Query simplification, view expansion,
normalization, optimization". Its body is the pipeline:

```lisp
(setq pred (andify (compilepredicate pred fno)))     ;; Generate TR pred
(setq pred (rewrite-before-view-expansion pred sb))
(setf (selectbody-orgpred sb) pred)                  ;; used when this fn is inlined elsewhere
(setq pred (expand-predicate pred nil))              ;; View expansion
(setq pred (rewrite-after-view-expansion pred sb))
(cond (*enable-aqit* (setq pred (aqit-fixpoint pred))))
(if *use-dnf* (setq pred (transformpredicate pred))) ;; Normalize to DNF
(setq pred (rewrite-after-normalization pred sb))
(setf (selectbody-pred sb) ...)
...
(setq pred (process_typechecks pred sb argl resl nil))
(optimize-pred pred sb fno)                          ;; Coercion and cost-based optimization
(setf (selectbody-delpred sb) (create-delpred (selectbody-optpred sb)))
```

**TR generation.** `compilepredicate` (:318) walks the flattened predicate. `AND`/`OR`/`OPTIONAL`
recurse. `compilefuneq` (:364) turns `f(args) = results` into the flat form `(f args… results…)`,
with inputs and outputs in one argument list, and rejects recursive derived functions (:376).
Foreign predicates pass through unchanged. The output is the **TR predicate**: `(AND (f1 …) (f2 …) …)`
over *resolved function OIDs*, with nothing yet decided about how any call will run.

**Rewriting** (`rewrite`, [rewrite.lsp:125](AmosNT_floq/lsp/rewrite.lsp#L125)). It runs three
times, and each run does:

- `add-boolean-assignments`: a bare boolean variable becomes `(= v true)`.
- `unify-key-preds` (:268), repeated until nothing changes:
  - `substequal`: substitute away `(= x y)`.
  - `inferequals` (:379): **key-based unification**. The docstring's example: `income(p,q) and
    income(p,r)` with a unique index on `p` ⇔ `q=r and income(p,r)`. `inferequals` is also where
    **TR rewrite rules** are applied (`get-tr-rewriter`, line 393) and where partial evaluation
    happens (`*enable-parteval*`).
- `rewrite-or-by-in`: `(OR (= X 1) (= X 2))` → `(IN (VECTOR 1 2) X)`.
- `rewrite-orinand`: rewrites OR clauses nested inside an AND. Variables shared across clauses are
  treated as free, so joins can pass through an OR.

**View expansion.** `expand-predicate` (:409) beta-expands every call to a derived function,
substituting the actual arguments into the callee's `orgpred` with fresh local variables. Stored
relations, foreign predicates and constructors are left alone (`expand-simple-pred`, :442). Views
are therefore optimized *together with* the query that uses them. The optimizer never sees a view
as a black box.

**AQIT** (Algebraic Query Inequality Transformation). `*enable-aqit*` is `nil` in `comppred.lsp`,
but the standard image turns it on. `_mexima-enabled_` is hard-coded to `t`
([lispdef.lsp:55](AmosNT_floq/lsp/lispdef.lsp#L55)), so `init.lsp:205–216` loads
[aqit/lsp/](AmosNT_floq/aqit/lsp/) and sets `*enable-aqit*`. The same load also installs the "late"
TR rewriters. Without it, `call-late-tr-rewriters0` is an identity stub
([rewrite.lsp:560](AmosNT_floq/lsp/rewrite.lsp#L560)) that AQIT replaces with
`call-late-tr-rewriters1` ([aqit/lsp/late-tr-rewrite.lsp:111](AmosNT_floq/aqit/lsp/late-tr-rewrite.lsp#L111)).

**Normalization.** `transformpredicate` → `normalizepred pred 'or`
([normalize.lsp:26](AmosNT_floq/lsp/normalize.lsp#L26)). "The current optimizer requires disjunctive
normal form predicates" ([rewrite.lsp:264](AmosNT_floq/lsp/rewrite.lsp#L264)).

`process_typechecks` (:273) only does work when `_ENABLE_DT_FLAG_` (derived types) is on. It is off
by default ([coredef.lsp:198](AmosNT_floq/lsp/coredef.lsp#L198)).

### 4.4 Optimization entry: `optimize-pred` and `decompose-pred`

[comppred.lsp:292](AmosNT_floq/lsp/comppred.lsp#L292): applies `coerce_expand`, rewrites once more,
then chooses a path:

```lisp
(cond ((mdb-optimization?)                       ; = (not _use_dtr_)
       (distributed-decomposition fno sb opt-coerced-pred))   ; legacy multi-DB
      (t (decompose-pred opt-coerced-pred sb)))  ; the normal path
```

[optimizer.lsp:499](AmosNT_floq/lsp/optimizer.lsp#L499):

```lisp
(defun decompose-pred (pred sb)
  "Do cost-based local optimization of PRED with selectbody SB"
  (let* ((*bindings* (selectbody-bindings sb))
         (pred0 (purge-void-preds pred sb))  ; Insert * for unused variables
         (argl (selectbody-argl sb)) pred1)
    (setf (selectbody-coercedpred sb) pred0)
    (setq pred1 (absorber-rewrite pred0))
    (setf (selectbody-absorbed sb) pred1)
    (finalize (optimize-compound-predicate pred1 argl) sb)))
```

(A commented-out `absorber-rewrite` call remains at comppred.lsp:206. The live call is here.)

### 4.5 Ordering: `optimize-compound-predicate` → `psort`

- `optimize-compound-predicate` (:513) dispatches on `AND` / `OR` / `OPTIONAL`.
- `optimize-conjunction` (:526) splits a conjunction into blocks with `and-blocks`, using OPTIONAL
  and OR as delimiters. **Compound blocks keep their positions**. Only the plain `AND` runs between
  them are sent to `psort` for reordering. Bound variables accumulate from block to block.
- `optimize-disjunction` (:543) optimizes each branch separately with the same inputs bound.

`psort` ([optimizer.lsp:1243](AmosNT_floq/lsp/optimizer.lsp#L1243)) picks the strategy from
`*optmethod*` (default `'ranksort`, [function.lsp:257](AmosNT_floq/lsp/function.lsp#L257)):

| `*optmethod*` | Function | Approach |
|---|---|---|
| `ranksort` (default) | `ranksort` (:1257) | Greedy: repeatedly place the cheapest-ranked executable predicate |
| `exhaustive` | `dynprogsort` ([dynprog.lsp:192](AmosNT_floq/lsp/dynprog.lsp#L192)) | Dynamic programming ("C.f. Selinger et al."). Limited to `_DYNPROG_MAX_TIME_` = 5 s, then falls back |
| `randomopt` | `random-opt` ([randomopt.lsp:139](AmosNT_floq/lsp/randomopt.lsp#L139)) | Randomized search (Joakim Naes, 1993) |

`ranksort`, trimmed:

```lisp
(while (not (atom l))
  (setq temp (get-best-rank l bnd))            ; rewriting happens here
  (cond (temp (setq minRankPred (rewrite-translated temp))
              (setq l   (rewrite-rest temp))
              (setq bnd (rewrite-bnd temp))
              (push minRankPred respart))
        ((every OR-clause l) ... distribute the rest of the conjunction into each OR branch ...)
        (t (non-exec-error (andify l) bnd))))  ; nothing is executable → "Query not executable."
```

**One greedy step, `get-best-rank`** (:1018). For each remaining predicate:

1. **`rewrite-preds`** (:1049) builds a `rewrite` record with the current binding pattern
   (`bindadornpat`) and asks the function's **TBR rewriters** (`get-rewriters`) first. A rewriter
   returns `success` (it produced a TBR), `substitute` (punt), or `nil` (failed). If no rewriter
   applies but the function supports this binding pattern (`moderesolvable`), it falls through to
   `substbindadorned`. A rewriter may also replace predicates in the remaining list; in that case
   the candidate list is reset and the scan starts again.
2. **`cost-rank`** (:963) scores the resulting TBR:
   ```lisp
   "Compute cost rank according to formula on pp 15 in lith-ida-r-92-24."
   (setq rank (/ (+ -1.0 fo) (max 0.0001 lc)))      ; rank = (fanout − 1) / cost
   ```
   Lowest rank wins. A predicate that filters (fanout < 1) gets a negative rank and is placed early.
   A cheap predicate that multiplies rows is placed late. This is the paper's formula R = (F−1)/C.
   See [litwin-risch-1992-objectlog.md](../amos-query-optimization/litwin-risch-1992-objectlog.md)
   ("Where `ranksort` gets its name").

### 4.6 Choosing the implementation: `bestmodefunction` and `substbindadorned`

`substbindadorned` (:1291) → `substbindadorned0` (:1323). For a foreign predicate it calls
`bestmodefunction` (:896), which walks every `tbr` of the function (`mapbpats`) and keeps those whose
pattern **covers** the actual one (`covers-dyn`: they need no more bound inputs than are available).
It then picks the one with **lowest cost, then lowest fanout, then lowest coverage**. There is an
honest TODO at :930: "why cost has precedence over fanout?".

The chosen implementation is emitted as a TBR call:

```lisp
`(call ,foreign-implementation ,(car pred) ,@(cdr pred))
;; foreign-implementation = (getprop impl 'extpred)  ; C function
;;                       or impl                     ; Lisp function
```

If the chosen implementation is itself a compiled derived function, `pre-optimized-plan` (:1347)
**inlines its already-optimized plan** instead, provided it is small enough
(`*max-substitutable-size*` = 10 primitive predicates, :453). A repeated variable among the
arguments gets an equality test added (`add-duplicate-param-test`, :1301).

### 4.7 Mediator hooks: absorber before, finalizer after

These come from BigIntegrator (Minpeng Zhu and Tore Risch, 2012). The framework, the relational
wrapper and FLOQ are covered in full in [BIGINTEGRATOR.md](BIGINTEGRATOR.md).

- **Absorber** ([absorbmng.lsp:33](AmosNT_floq/BigIntegrator/src/Lisp/absorbmng.lsp#L33)). For
  each *source predicate* (a function with the `cclusterfct?` property), it finds the wrapper for
  that source (`get_absorber`) and lets it **absorb** neighbouring predicates. The result is one
  *access filter* (an `expression` with filter, source and finalizer), and the absorbed predicates
  are removed. This repeats until nothing changes. Wrappers register their absorber in AmosQL with
  `set_absorber` ([integrator.amosql:46](AmosNT_floq/BigIntegrator/src/AmosQL/integrator.amosql#L46)),
  e.g. `set_absorber('relational', 'absorb-sql')`
  ([wrappers/relational/configuration.osql:14](AmosNT_floq/wrappers/relational/configuration.osql#L14)).
- **Finalizer** ([finalizermng.lsp](AmosNT_floq/BigIntegrator/src/Lisp/finalizermng.lsp)). The file
  defines `finalize` twice. The first definition (line 41) is disabled by being wrapped in
  `(quote …)`. **The live one (line 74) re-optimizes**:
  ```lisp
  (defun finalize (tbr sb)
    (let ((finalizedtbrl (finalize1 tbr sb)) trl)       ; wrappers translate access filters
      (setq trl (map-over-pred finalizedtbrl
                   (f/l (atbr) (if (consp atbr) (getcalledpred atbr)))  ; TBR → back to TR
                   (function id)))
      (optimize-compound-predicate trl (selectbody-argl sb))))    ; order again
  ```
  So after each wrapper has turned its access filter into a real call (e.g. an SQL string), the
  whole plan is converted back to TR and **cost-optimized a second time**. For queries without
  wrapped sources this is simply a second ranking pass over the same predicates.
- `adjust-filter` (:178) contains the checkout's uncommitted work. Its comment says: "this is newer
  code compared to cvs … it can't pass regress yet". This matches the root
  [readme.txt](AmosNT_floq/readme.txt).

---

## 5. Cost model

**Where a (cost, fanout) comes from**, in order:

1. **Declared cost hint**: `getdeclaredcosts` (:1183) → `getcosthint`
   ([TBR.lsp:179](AmosNT_floq/lsp/TBR.lsp#L179)). This is either a constant `(cost fanout)` or a
   cost function called with `(fno, bpat-vector, args-vector)`. Set with `declarecosts` (:170). It is
   how wrappers and your hand-written foreign functions report real costs.
2. **Stored relation**: `localcost` (:1215) and `fanout-relation`. With a usable index the cost is
   `2 × index-fanout`, otherwise `2 × cardinality` (a full scan). `index-fanout` (:1152): a unique
   index gives 0.99; a non-unique one gives `cardinality / distinct keys`; an empty index gives 2.0.
3. **Defaults** ([optimizer.lsp:396–426](AmosNT_floq/lsp/optimizer.lsp#L396)):

   | Constant | Value | Applies to |
   |---|---|---|
   | `_default-foreign-cost_` / `-fanout_` | 0.5 / 0.99 | single-valued foreign function |
   | `_default-bagres-cost_` / `-fanout_` | 100 / 100 | bag-valued function |
   | `_default-aggregate-cost_` / `-fanout_` | 100.0 / 0.99 | aggregate |
   | `_default-combiner-cost_` | 1000 | bag-valued aggregate |
   | `_default-selectivity_` | 0.4 | predicate with all arguments bound (a test) |
   | `_default-index-fanout_` / `_default-key-fanout_` | 2.0 / 0.99 | empty index / unique index |
   | `_default-relation-cardinality_` | 100 | empty stored function |
   | `_max-sampled-tuples_` | 1000 | cap when sampling for selectivity |

**Combining costs** (:1101–1128):
- Conjunction: `cost = Σ costᵢ × Π(fanouts before i)` and `fanout = Π fanoutᵢ`, i.e. the cost of
  nested loops.
- Disjunction: costs add and fanouts add.
- A constant costs `(1 0)`. A variable costs `(1 0.01)`.

**Caching.** `exec-cost-of-fn` / `exec-cost-of-tbr` (:468, :475) store `(cost fanout)` on the
function object (property `cost`). The first request for a new binding pattern triggers
`bpat-optimize-function`, so optimization is **lazy**. `uncache-costs` (:553) clears a function's
cached cost and, recursively, the cost of everything that uses it.

**Unexecutable plans.** If no ordering binds every variable, `non-exec-error` (:859) raises "Query
not executable … Unbound variables: …". During speculative costing, `catch-exec-error` turns that
error into a plain failure, and the binding pattern is marked `'fail` in its `tbr`.

---

## 6. Two kinds of rewrite rules

| | TR rewriters | TBR rewriters |
|---|---|---|
| Registered by | `define-tr-rewriter fn test action` ([rewrite.lsp:431](AmosNT_floq/lsp/rewrite.lsp#L431)) | `add-rewriter fn bpat rewriter` ([TBR.lsp:235](AmosNT_floq/lsp/TBR.lsp#L235)) |
| Stored | function property `tr-rewriter` (one per function; falls back to the generic function) | list in the `tbr` for a binding pattern; looked up by the *best covering* pattern |
| Runs | in `inferequals` during each `rewrite` pass, i.e. before cost-based optimization | in `rewrite-preds`, inside the greedy loop, once the binding pattern is known |
| Knows bindings? | No: logical, independent of bindings | Yes: physical |
| Examples | `vref`, `makebag` ([tr-rewrites.lsp:20,48](AmosNT_floq/lsp/tr-rewrites.lsp#L20)) | index access: creating an index whose type has an `index-rewriter` registers it with `add-rewriter` ([relation.lsp:78](AmosNT_floq/lsp/relation.lsp#L78)). This is how `mbtree` range access is wired in |

Your [query-rewrite/](../amos-query-optimization/query-rewrite/) notes exercise the TBR side from the
REPL: `add-rewriter`, `get-rewriters`, the `REWRITE` struct and its return values. §4.5 above is the
code that calls those rewriters.

---

## 7. Worked example (reconstructed from the source, not captured)

From [demo/tutorial.amosql:54](AmosNT_floq/demo/tutorial.amosql#L54):

```
create function host_name(Integer y)->Charstring hn
 as select name(host(t)) from Tournament t where year(t)=y;
```

`year`, `host` and `name` are stored functions. Variable names below are illustrative; the compiler
generates its own.

| Stage | Shape | Where |
|---|---|---|
| Parsed | `select`-body with result `name(host(t))`, `from ((Tournament t))`, `where (= (year t) y)` | parser.y |
| Flattened + resolved | `year(t)=y`, `host(t)=c`, `name(c)=hn`, with `name` resolved to `name(Country)` because `host` returns `Country` | `flattenfuncall` → `resolveargs` |
| TR (`pred`) | `(AND (year t y) (host t c) (name c hn))`, plus the type-check predicate that `gen_typechecks` generates for `t` | `compilepredicate` |
| Forward plan, bpat `(- +)` (y bound) | Only `year` can use the bound `y`. Placing it first means looking up tournaments by `year` value, which is cheap only if there is an index on that position; otherwise the cost model prices a scan (§5). Then `host` with `t` bound, then `name` with `c` bound: each step becomes `(call <impl> year t y)` etc. | `ranksort` / `bestmodefunction` |
| Inverse plan, bpat `(+ -)` (hn bound) | Compiled separately, the first time something calls `host_name` with its *result* bound, e.g. `select y from Integer y where host_name(y)='Sweden'`. The greedy loop can then start from `name` with `hn` bound. | `bpat-optimize-function` |

What the example shows: nesting disappears when the query is flattened, overloaded `name` is resolved
from the result type of `host`, and the same function carries two independent plans. For real `pc()`
output of plans like this, see
[tutorial-index-execution-plans.md](../amos-query-optimization/tutorial-index-execution-plans.md).

---

## 8. Inspecting plans

| Function | Where | Use |
|---|---|---|
| `pc` | [optimizer.lsp:641](AmosNT_floq/lsp/optimizer.lsp#L641) | print the execution plans of a function (argument required) |
| `objlog` | :595 | `(pc (compile-query query))`: compile a query string into `_select_` and print its plan |
| `qplan` | :599 | return (not print) the `optpred` of a compiled query string |
| `ppt` / `plan-trail` | :603 / :607 | the plan with each call reduced to the name of the function it runs |
| `*printopt*`, `*optlog*` | :435–436 | trace each ranking decision (`printopt` calls in `ranksort`, `cost-rank`) |
| `_save-intermediates_` | comppred.lsp:130 | keep every stage in the `selectbody` fields (§3) |

---

## 9. What is not part of the query pipeline

- **`rule_compiler.lsp`** is the compiler for **ECA (event-condition-action) triggers**. Its
  generated event/condition/action functions are ordinary derived functions that go through the
  pipeline above, but it adds nothing to the optimizer. It is loaded only by `eca_rules.lsp:40`,
  which `init.lsp:174` loads only when `_eca-enabled_` is set. It is `nil`
  ([coredef.lsp:189](AmosNT_floq/lsp/coredef.lsp#L189)).
- **The `qd_*` multi-database decomposition** (`qd.lsp`, "Distributed Selective View Expansion", …)
  runs only when `mdb-optimization?` is true, i.e. when `_USE_DTR_` is off. It is on by default.
- **`*old-decompose*`** switches `decompose-pred` to `old-decompose-pred`, marked obsolete in the
  code.

---

## 10. Mapping to your existing notes

| Concept in your notes | Where it lives in this source |
|---|---|
| Paper pipeline: Flattener → Type Checker → ObjectLog Generator → Optimizer ([litwin-risch-1992-objectlog.md](../amos-query-optimization/litwin-risch-1992-objectlog.md)) | `flatten.lsp` + `typecheck.lsp`, merged into one pass (§4.2) → `compilepredicate` (§4.3) → `optimizer.lsp` (§4.4–4.6) |
| Rank R = (F−1)/C | `cost-rank`, optimizer.lsp:963 |
| TR / TBR | `selectbody-pred` / `selectbody-optpred`; the `tbr` struct |
| `optmethod('exhaustive')`, your `dynprogsort` assignment ([amos-query-optimization-assignment/](../amos-query-optimization/amos-query-optimization-assignment/)) | `psort` dispatch, optimizer.lsp:1243; the built-in `dynprog.lsp`. The helpers your code called (`bindadornpat`, `simple-pred-cost-bnd`, `substbindadorned`) are in `optimizer.lsp` |
| Cost-based vs rule-based ([cost-based-vs-rule-based-optimization.md](../amos-query-optimization/cost-based-vs-rule-based-optimization.md)) | Rules only rewrite (§6). Every ordering decision goes through `cost-rank` or `dynprogsort` (§4.5) |
| Mongo wrapper's `set_extractor` / `set_finalizer` / `set_costmodel` ([query-translation.md](../amos-query-optimization/mongo-wrapper/query-translation.md)) | **Not in this checkout.** The 2013 mediator API is `set_absorber` / `set_finalizer` (§4.7), with costs coming from cost hints (§5). The *extractor* in your notes plays the absorber's role, probably a later rename, but that is inferred. This checkout's [wrappers/Mongo/](AmosNT_floq/wrappers/Mongo/) is the older C-only wrapper, with no absorber and no part in optimization. |
