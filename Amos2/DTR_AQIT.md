# Late binding (DTR) and AQIT

Two mechanisms that are **on by default** and change the plans the optimizer produces, but that
[QUERY_COMPILER.md](QUERY_COMPILER.md) only mentions:

- **Late binding.** Choosing the right definition of an overloaded function at *run time*, when the
  types of the actual objects aren't known at compile time.
- **AQIT** (Algebraic Query Inequality Transformation). Rewriting inequalities over expressions, such
  as `x*2 + 1 > 10`, into conditions directly on an indexed variable (`x > 4.5`), so that a range
  index can be used.

Source: [lsp/DTR.lsp](AmosNT_floq/lsp/DTR.lsp), [lsp/latebind.lsp](AmosNT_floq/lsp/latebind.lsp),
[lsp/flatten.lsp](AmosNT_floq/lsp/flatten.lsp) and [aqit/lsp/](AmosNT_floq/aqit/lsp/). Nothing was run;
line numbers refer to this checkout. Terms: [GLOSSARY.md](GLOSSARY.md).

---

## Part 1 — Late binding

### 1.1 The problem

AmosQL functions are overloaded on their argument types. `name(Person)` and `name(Country)` are two
*resolvents* of the *generic* function `name`. Normally the compiler picks the resolvent while
flattening, from the declared types of the arguments
([QUERY_COMPILER.md §4.2](QUERY_COMPILER.md#42-flattening-overload-resolution-and-type-checks-compileselect)).

Static types are not always precise enough. With `create type Referee under Person`, a variable
declared `Person` may hold a `Referee` at run time. If `name` also has a resolvent for `Referee`, the
correct one can only be chosen once the object is known. That is late binding.

### 1.2 When the compiler asks for it

`latebinding-reqd?` ([flatten.lsp:449](AmosNT_floq/lsp/flatten.lsp#L449)):

```lisp
(and (not (early-bound gfno))
     (let* ((rl (subset (resolvents gfno)
                        (f/l (r) (and (eq (length (get-resolvent-argtypes r)) arity)
                                      (subtype-of (get-resolvent-argtypes r) argtypes t))))))
       (cdr rl)))                        ; more than one candidate → late binding
```

**Late binding is needed when more than one resolvent's argument types are subtypes of the call's
static argument types.** In other words, the actual objects could turn out to be of several more
specific types, each with its own definition. A generic function can opt out with `set-early-bound`
(:466), which sets the `early-bound` property.

`flattenfuncall` checks this at [flatten.lsp:413](AmosNT_floq/lsp/flatten.lsp#L413) (the
`(and _USE_DTR_ (latebinding-reqd? gfno fargs))` branch). `_USE_DTR_` is **on**
([coredef.lsp:124](AmosNT_floq/lsp/coredef.lsp#L124)).

### 1.3 Mechanism A (default): the `dtr` predicate

`flattenlatebinding` ([flatten.lsp:478](AmosNT_floq/lsp/flatten.lsp#L478)) replaces the call with

```lisp
(*_dtrfunction_* <candidate resolvents, most specific first> args…)
```

- **The candidates** come from `generate-resolvent-list` (the resolvents that could apply to
  instances of the static types). `sort-resolvent-list` (:494) orders them by subtype, most specific
  first.
- **Compile-time error.** If even the most general candidate is more specific than the static types,
  some objects would have no definition, and compilation fails with "Function … not defined for …".
- **`*_dtrfunction_*`** is the built-in function `dtr`, created at boot
  ([boot.lsp:202](AmosNT_floq/lsp/boot.lsp#L202)) as `multidirectional` with binding patterns `bbf`
  and `bfb`. Both are implemented by the Lisp function `dtr--+`
  ([DTR.lsp](AmosNT_floq/lsp/DTR.lsp), Magnus Werner, Staffan Larsson and Tore Risch, 1993).

**At run time**, `dtr--+`:
1. calls `match-args-to-resolvents` to keep the candidates whose argument types the *actual* objects
   satisfy (`applicable*?`);
2. takes the **first** of them. Because the list is sorted most specific first, that is the most
   specific applicable definition;
3. **forward** (arguments bound): calls it with `mapfunction` and emits its results;
4. **backward** (results bound, e.g. "which objects have this name?"): runs each applicable
   resolvent's inverse plan (`dtr-+-`), temporarily installing that plan in a dummy function.

**In the optimizer:**
- `bestmodefunction` returns the fixed implementation `(dtr--+)` for a `dtr` call.
- Costs come from `dtr-simple-pred-cost` ([DTR.lsp:265](AmosNT_floq/lsp/DTR.lsp#L265)), which costs
  every candidate for the binding pattern, sorts them with `cost_cmp` (descending, :260) and takes the
  first. **A `dtr` call is costed pessimistically, as its most expensive candidate.** If any candidate
  can't run under the binding pattern, the call isn't executable in that position.
- TR generation treats `dtr` calls specially (`dtr?` in `compilepredicate`,
  [comppred.lsp:333](AmosNT_floq/lsp/comppred.lsp#L333)). Binding patterns are computed from the
  first candidate (`dtr-bindadornpat`), since all candidates bind the same variables.

### 1.4 Mechanism B: a compiled dispatch function

[latebind.lsp](AmosNT_floq/lsp/latebind.lsp) (Vanja Josifovski, 1998) builds the dispatch as a
**query** instead of a run-time Lisp function. `gen_lb_exec_func` generates a transient function
whose body is an OR with one branch per candidate. Each branch is guarded by a type test on the
arguments:

```
OR( AND( Referee ∈ typesof(x),  name_Referee(x) = r ),
    AND( x ∈ shallow_extent(Person),  name_Person(x) = r ) , … )
```

The tests are generated most specific first (`gen-tpc-code`, `gen-tpchk`), using a type's extent
function or shallow extent where it can, and `typesof` otherwise. The body then goes through the
ordinary `compile_phase2`, so the dispatch becomes a normal optimized plan with no special run-time
code. An ambiguous set of candidates raises "Cannot find non-ambigous resolvent among: …".

**When it is used:**
- Adding a new resolvent to a function runs `chain_set_lb` ([function.lsp:468](AmosNT_floq/lsp/function.lsp#L468)).
  It marks dependents for recompilation (`need_recomp`) and prepares a dispatch function for each
  sibling resolvent (`set_lb`). The function is built lazily: its property `late_b_exec_func` starts
  as `not_created`, and `get_lbex_func` builds it on first use (also from recompilation,
  [recompile.lsp:185](AmosNT_floq/lsp/recompile.lsp#L185)).
- The compiler reaches it through `get-lbresolv-function` ([flatten.lsp:439](AmosNT_floq/lsp/flatten.lsp#L439)),
  in the *non-DTR* branch of `flattenfuncall`, for a function that has a dispatch function and still
  needs late binding. The code carries the comment `; hack for IUT`. IUTs (integration union types)
  belong to the older multi-database system, so this path matters mainly there and when `_USE_DTR_`
  is off.
- For derived types that aren't integration types, `gen_lb_exec_func` just returns the first
  candidate, with the comment "This is not implemented yet".

### 1.5 Summary

| | Mechanism A: `dtr` | Mechanism B: dispatch function |
|---|---|---|
| Built by | `flattenlatebinding` (flatten.lsp:478) | `gen_lb_exec_func` (latebind.lsp) |
| Dispatch | Run time, in Lisp (`dtr--+`): first applicable of a sorted list | Compiled OR of type-guarded branches |
| Optimizer sees | One opaque call, costed as its worst candidate | An ordinary predicate it can optimize |
| When | Default (`_USE_DTR_` on) | Non-DTR path; IUT "hack"; after `chain_set_lb` |

In practice, most late binding in a standard image goes through mechanism A. Its costing makes
overloaded calls look expensive, so the optimizer places them late when it can.

---

## Part 2 — AQIT

### 2.1 What it is for

A range index (`mbtree`, [STORAGE.md §7.4](STORAGE.md#74-how-a-range-index-gets-into-a-plan-mbtree))
can answer `x > 4.5` on an indexed column `x`. It can't answer `x*2 + 1 > 10` as written, because the
inequality is on an expression. After flattening that is
`(times x 2 v1) ∧ (plus v1 1 v2) ∧ (> v2 10)`, and the inequality is on `v2`. AQIT solves the chain
algebraically for `x`, giving `x > (10 − 1)/2`. The index rewriter then turns that into a range scan.

AQIT is Thanh Truong's work (UDBL, 2011–13). **It is on in the standard image**
(`_mexima-enabled_` → [init.lsp:205–216](AmosNT_floq/lsp/init.lsp#L205) loads
[boot-aqit.lsp](AmosNT_floq/aqit/lsp/boot-aqit.lsp) and sets `*enable-aqit*`). Its design notes are in
[aqit/doc/aqit.txt](AmosNT_floq/aqit/doc/aqit.txt) and examples in
[aqit/doc/examplesV1.txt](AmosNT_floq/aqit/doc/examplesV1.txt).

### 2.2 Which version runs

The design notes describe the first version (`aqit.lsp`). There, AQIT registered **late TR
rewriters** for `<`, `<=`, `>` and `>=` (`define-late-tr-rewriter … 'aqit-tester 'aqit-rewriter`).
**`aqit.lsp` is not loaded any more.** `boot-aqit.lsp` loads version 2, which works differently:

- `compile_phase2` calls **`aqit-fixpoint`** directly, after view expansion and before DNF
  normalization ([comppred.lsp:187–189](AmosNT_floq/lsp/comppred.lsp#L187);
  [aqitv2.lsp:6](AmosNT_floq/aqit/lsp/aqitv2.lsp#L6)). No inequality rule is registered.
- The late TR rewriter mechanism is still installed (`late-tr-rewrite.lsp`), and is used by the
  **distance** rules (§2.5).

That is why [REWRITE_RULES.md](REWRITE_RULES.md) shows the inequality registrations as outside the
image, while AQIT is still active.

### 2.3 The algorithm (version 2)

```
aqit-fixpoint(pred):   repeat transform-pred until nothing changes; then aqit-gcp
transform-pred(pred):
    OR  → transform every branch; fail if any branch fails
    AND → irec  = chain(pred)          find an indexed-inequality path (IIP)
          irec' = expose(irec)         solve it algebraically for the indexed variable
          → substitute the result for the conjunction
```

**`chain`** (aqitv2.lsp:42) finds an **IIP, an Indexed Inequality Path**:
1. **Start** at the first *not-yet-exposed* indexed variable, i.e. one that doesn't already appear
   directly in an inequality (`first-not-exposed-indexed-variable`,
   [miscv2.lsp:156](AmosNT_floq/aqit/lsp/miscv2.lsp#L156)). Only indexes of an
   **AQIT-supported type** count: `_aqit-supported-indexes_`, which starts as `(MBTREE)`
   ([boot-aqit.lsp:3](AmosNT_floq/aqit/lsp/boot-aqit.lsp#L3)) and is extended when the rewrite matrix
   gets entries (§2.5). Wrapped sources with their own index descriptors also count (`get-ccindex`,
   [ud-index-cc.lsp](AmosNT_floq/aqit/lsp/ud-index-cc.lsp)). Candidates are sorted by index
   cardinality.
2. **Extend** the path through predicates that share a variable (`extend-partial-iip`, `connected`),
   until it ends at a comparison `<`, `<=`, `>` or `>=` (`complete-iip`, miscv2.lsp:55).
3. **OR blocks.** If no path exists in the plain conjunction, try each OR block. A path must exist
   in **every** branch of the block (`chain-orpred`), and the rest is distributed into the other
   blocks.
4. Before that, `simplify-division-tester` / `-writer` simplify divisions in the conjunction.

**`expose`** (aqitv2.lsp:135) repeatedly looks at the two path nodes nearest the comparison, an
arithmetic predicate and the comparison, and applies the **first matching algebraic rule** from
`_aqit-algebraic-rules_` ([algebraic-rules.lsp](AmosNT_floq/aqit/lsp/algebraic-rules.lsp)). This moves
the comparison one step closer to the indexed variable, and it repeats until no intermediate node is
left. A rule that yields an OR (unknown sign) makes each branch be exposed separately.

**`aqit-gcp`** ([miscv2.lsp:1](AmosNT_floq/aqit/lsp/miscv2.lsp#L1)) then pulls predicates common to
all OR branches out of the OR.

### 2.4 The 18 algebraic rules

`θ` is the comparison; `θ'` is the flipped comparison (`<` ↔ `>`, `<=` ↔ `>=`). `p` is the variable
one step nearer the index, `v` the intermediate result, `A` and `B` the other operands.

| Rules | Operation | Rewrite |
|---|---|---|
| 1–3 | `v = A − p`, `v = p − A`, `v = p + A` | move `A` across: e.g. `(v = p + A) ∧ v θ B` ⇒ `p θ B − A` |
| 4 | `v = p × A`, `A > 0` | `p θ B/A` |
| 5 | `v = p × A`, `A < 0` | `p θ' B/A` |
| 6 | `v = p × A`, sign unknown | `OR(p θ B/A ∧ A > 0, p θ' B/A ∧ A < 0)` |
| 7–9 | `v = p / A` with `A` > 0, < 0, unknown | `p θ B·A`, `p θ' B·A`, or an OR of both |
| 10–12 | `v = A / p`, compared with 0 | `p θ 0` / `p θ' 0` by the sign of `A`, or an OR |
| 13–14 | `v = A / p`, compared with `B ≠ 0` | an OR over the signs of `p` and `B` |
| 15 | `sqrt(p) θ B` | `p θ B²` |
| 16 | `power(p, A) θ B` | `p θ B^(1/A)` |
| 17 | `abs(p) < B` | `p > −B ∧ p < B` |
| 18 | `abs(p) > B` | `p > B ∨ p < −B` |

(The rule-to-number mapping follows the order of `_aqit-algebraic-rules_` and the comment headers in
the file. Rules 13–14 are the two `d6` cases.)

**Signs** come from the query itself. `is-positive?` / `is-negative?`
([miscv2.lsp](AmosNT_floq/aqit/lsp/miscv2.lsp)) look for a sign condition on the operand in the same
conjunction. When there is none, the sign-dependent rules produce an OR that covers both cases, and
the OR is optimized like any other.

The rules for `sqrt` and `power` don't check signs or domains the way the division rules do. From the
comments alone it can't be told whether that is intentional, e.g. relying on non-negative data.

### 2.5 Distance predicates and the rewrite matrix

The second half of AQIT handles similarity search: "find points within distance `d` of `q`" on a
multidimensional index.

- **The rewrite matrix** ([rewrite-matrix.lsp](AmosNT_floq/aqit/lsp/rewrite-matrix.lsp)) says which
  **distance function** on which **index type** can be answered by which **access-method function**.
  Entries are added from AmosQL:
  ```sql
  add_index_rewrite_rule('XTREE', #'euclid', #'XTREE_DISTANCE_SEARCH_FN');
  add_knn_rewrite_rule('XTREE', 'XTREE_KNN_SEARCH_FN');
  ```
  Adding an entry also adds the index type to `_aqit-supported-indexes_`.
- **In the standard image** these entries come from
  [system/C/mexima/lsp/internal-xtree.lsp:12–24](AmosNT_floq/system/C/mexima/lsp/internal-xtree.lsp#L12):
  `euclid`, `manhattan`, `minkowski` and `intersection_distance` on XTREE, plus k-NN. That file is
  loaded only if the XTREE extender loads ([STORAGE.md §7.3](STORAGE.md#73-the-extenders)).
- **The rules**: late TR rewriters on `euclid` and `minkowski`
  ([dist-based-index-rewrite2.lsp:245–247](AmosNT_floq/aqit/lsp/dist-based-index-rewrite2.lsp#L245)).
  `distance-based-index-tester` (:190) fires when the conjunction has an inequality, and a stored
  function with an AQIT-supported index whose type has a matrix entry for this distance function.
  `distance-based-index-rewriter` normalizes the inequalities so the distance variable is on the
  left, sorts the indexed predicates, and replaces the pattern with the access-method call
  (`rewrite-distance-based-index`).
- **KDTREE** examples of the same matrix are in
  [applications/ExtensibleIndexes/](AmosNT_floq/applications/ExtensibleIndexes/). This is the
  extensible-index lab that your
  [uu-db2-assign3-extensible-index](../uu-db2-assign3-extensible-index/) notes are built on.

### 2.6 How AQIT and the index rewriter work together

| Stage | Component | For `x*2 + 1 > 10` with an `mbtree` index on `x` |
|---|---|---|
| TR, after view expansion | AQIT (`aqit-fixpoint`) | rewrites the chain to `x > 4.5` |
| TR | normal rewriting, DNF | — |
| TBR, in the greedy loop | `rewrite-mbtindex` (index rewriter) | `x > 4.5` on the indexed position → `mbt-select-range(…, low = 4.5, …)` plus `x != 4.5` |
| Cost | `mbt-select-cost` | `max(1, 4·log₅₀₀ |R|)`, fanout 4 |

Without AQIT, the comparison stays on `v2` and the relation is scanned. **AQIT only fires when an
index of a supported type exists.** With only the default hash indexes, it finds no starting
variable and leaves the query unchanged.

### 2.7 Loose ends

| Where | What |
|---|---|
| `aqit/doc/aqit.txt` | Describes version 1 (registered late TR rules, `aqit-entry`, `aqit-groupping`). The image runs version 2 (`aqit-fixpoint`, `chain`, `expose`) |
| `miscv2.lsp:104` | Comment says "Need to sort indexes descending on their cardinalities"; `sort-indexes` sorts ascending (`<`) |
| `aqitv2.lsp:159` | `subsitute` (sic) ignores its first two arguments and returns the exposed path |
| `algebraic-rules.lsp` rules 15–16 | `sqrt`/`power` inversions without the sign handling the division rules have |
| `aqit/lsp/` | Several unloaded variants (`aqit.lsp`, `niceraqit.lsp`, `dist-based-index-rewrite.lsp`, `aqitmisc.lsp`); see [REWRITE_RULES.md](REWRITE_RULES.md) for which registrations are live |
