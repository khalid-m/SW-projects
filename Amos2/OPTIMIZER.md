# The optimizer, part 2: costs, strategies, rewrite rules

Detail that [QUERY_COMPILER.md](QUERY_COMPILER.md) only summarizes: where each cost number comes from
(with a worked calculation), the three join-ordering strategies, how rewrite rules are used in
practice, and how compiled plans are reused and recompiled. Read QUERY_COMPILER.md §4–6 first. All
source is in [AmosNT_floq/lsp/](AmosNT_floq/lsp/). Nothing was run: the worked example is calculated
by hand from the formulas. Line numbers refer to this checkout.

Companions: [REWRITE_RULES.md](REWRITE_RULES.md) (generated catalogue of every rule registration) and
[STORAGE.md](STORAGE.md) (relations and indexes, which supply the statistics used here).

---

## 1. Controlling the optimizer from AmosQL

Defined in [amosfns.lsp:1950–1990](AmosNT_floq/lsp/amosfns.lsp#L1950):

| Function | Effect |
|---|---|
| `optmethod('ranksort' \| 'exhaustive' \| 'randomopt')` | Sets `*optmethod*`, which `psort` dispatches on (§3). Default `ranksort` |
| `optlevel(x, y)` | `randomopt` parameters: number of local minima and number of random walks (§3.3) |
| `opttrace(true)` | Sets `*printopt*`: prints each ranking decision, the DP iterations, and the random-search minima |
| `optlog('file')` | Sends that trace to a file (`*optlog*`) |
| `enable_parteval(bool)` | Turns partial evaluation during TR rewriting on or off (`*enable-parteval*`, default on) |

`optmethod` only sets the global. **Functions that are already compiled keep their plans** until they
are recompiled (§5). Ad hoc queries are compiled fresh every time, so they pick up the change at once.

---

## 2. Where the numbers come from

Every predicate in a conjunction is costed by `compute-exec-cost-pred`
([optimizer.lsp:847](AmosNT_floq/lsp/optimizer.lsp#L847)), which returns `(cost fanout)`:

- **cost**: the work to evaluate it *once* for one set of bound inputs, in abstract units;
- **fanout**: the expected number of result tuples per evaluation. Below 1 means a filter; above 1
  means it multiplies rows.

For a simple predicate `simple-pred-cost-bnd` (:982) computes the binding pattern (`bindadornpat`),
then takes the first applicable source:

```
1. declared cost hint?   getdeclaredcosts → getcosthint (TBR.lsp:179)
      constant (cost fanout)  or  a cost function called with (fno, bpat, args)
2. stored relation?      localcost + fanout-relation                 (§2.1)
3. otherwise (foreign)   defaults by kind: single-valued 0.5 / 0.99, bag 100 / 100,
                         aggregate 100 / 0.99, combiner 1000 / 100    (optimizer.lsp:396–419)
   all arguments bound → fanout = _default-selectivity_ = 0.4 (a test)
```

A DTR call (late binding) is costed by `dtr-simple-pred-cost` instead. Constants cost `(1 0)` and
variables `(1 0.01)`. An unexecutable binding pattern returns `nil`, and the predicate can't be placed
yet.

### 2.1 Stored relations

These are the relations behind stored functions ([STORAGE.md §3](STORAGE.md#3-stored-functions-and-their-relations)).

**Cost** (`localcost`, [optimizer.lsp:1215](AmosNT_floq/lsp/optimizer.lsp#L1215)):

```
if some bound position has an index:   cost = 2 × index-fanout(index, |R|)
else:                                  cost = 2 × |R|          (a full scan)
```

**Fanout** (`fanout-relation`, [optimizer.lsp:1376](AmosNT_floq/lsp/optimizer.lsp#L1376)):

```
fanout = |R| × ∏ over BOUND positions i of sel(i)

   sel(i) = index-fanout(index_i, |R|) / |R|     if position i has an index
   sel(i) = 1 / (distinct values of column i)    otherwise, by sampling
```

- **`index-fanout`** (:1152): 0.99 for a unique index. For a non-unique one, `|R| / distinct keys`
  (from the C index's `cardinality`). For an empty index, 2.0.
- **Sampling** (`estimate-pos-selectivity`, :1401) scans the relation's first index for **at most
  1000 rows** (`_max-sampled-tuples_`) and counts distinct values in that column. It is **recomputed on
  every call**: the hash table is cleared each time, and nothing is cached except the finished plan's
  cost.
- **`fudge-key-fanout`** (:1395) turns any result between 0.99 and 1.0 into 0.99, "to avoid making
  fanout = 1.0". A fanout of exactly 1 would give a rank of 0 (§3.1), making the predicate neither a
  filter nor an expander.

**Assumptions built into these formulas:**
- Positions are **independent**, since the selectivities are multiplied together.
- Values are **uniform**, since `1/distinct` ignores skew.
- The first 1000 rows are **representative** of the whole relation.

These are the failure modes your
[cost-based-vs-rule-based-optimization.md](../amos-query-optimization/cost-based-vs-rule-based-optimization.md)
observed from outside. This is where they come from.

### 2.2 Combining predicates

`andpredcost` / `orpredcost` ([optimizer.lsp:1101, 1116](AmosNT_floq/lsp/optimizer.lsp#L1101)):

```
AND (in plan order):   cost   = c₁ + f₁·c₂ + f₁·f₂·c₃ + …      (nested loops)
                       fanout = f₁ · f₂ · f₃ · …
OR:                    cost   = Σ cᵢ         fanout = Σ fᵢ
```

The cost of a derived function's plan (`compute-exec-cost`, :835) is this sum over its `optpred`, and
it is cached on the function (§5). When the function is used inside another query, that cached
`(cost fanout)` is what the outer optimizer sees.

### 2.3 Worked example: `host_name` by hand

This is the function from [QUERY_COMPILER.md §7](QUERY_COMPILER.md#7-worked-example-reconstructed-from-the-source-not-captured):
`select name(host(t)) from Tournament t where year(t)=y`, called with `y` bound.

**Assumptions:** 20 tournaments with 20 distinct years; the stored functions `year`, `host` and `name`
each have 20 rows and only their default unique hash index on the first argument ([STORAGE.md §3](STORAGE.md#3-stored-functions-and-their-relations)).
After view expansion, the TR predicate is `p_year(t,y) ∧ p_host(t,c) ∧ p_name(c,hn)` with `y` bound.

**Step 1.** Nothing but `y` is bound. The candidates:

| Predicate | Bound | Cost | Fanout | Rank (F−1)/C |
|---|---|---|---|---|
| `p_year(t, y)` | `y` (position 1, **no index**) | 2 × 20 = **40** (scan) | 20 × 1/20 = 1.0 → fudged **0.99** | −0.00025 |
| `p_host(t, c)` | nothing | 40 | 20 | +0.475 |
| `p_name(c, hn)` | nothing | 40 | 20 | +0.475 |

`p_year` has the lowest rank and goes first. It binds `t`.

**Step 2.** With `t` bound, `p_host` uses its unique index on position 0: cost = 2 × 0.99 = **1.98**,
fanout = 20 × 0.99/20 = **0.99**, rank ≈ −0.005. It goes second and binds `c`.

**Step 3.** `p_name(c, hn)` with `c` bound: likewise 1.98 / 0.99.

**Plan cost** = 40 + 0.99 × 1.98 + 0.99 × 0.99 × 1.98 ≈ **43.9**, fanout ≈ 0.97.

The scan of `year` dominates. A non-unique index on `year`'s result position (`createindex`,
[relation.lsp:198](AmosNT_floq/lsp/relation.lsp#L198)) would make step 1 cost 2 × index-fanout =
2 × (20/20) = 2, and the plan cost about 5.9. With
real data, the first-row sample and the default index statistics can mislead this calculation in
exactly the ways listed in §2.1.

---

## 3. Join-ordering strategies

`psort` ([optimizer.lsp:1243](AmosNT_floq/lsp/optimizer.lsp#L1243)) orders each plain `AND` block
([QUERY_COMPILER.md §4.5](QUERY_COMPILER.md#45-ordering-optimize-compound-predicate--psort)). All three
strategies call the same per-predicate costing (§2) and emit the same TBR form through
`substbindadorned`.

### 3.1 `ranksort` (default): greedy by rank

One pass: at each step, rewrite and cost every remaining predicate under the current bindings
(`get-best-rank` → `rewrite-preds` → `cost-rank`) and place the one with the lowest
`(fanout − 1) / cost`. There are *n* steps with up to *n* candidates each, so O(n²) cost evaluations.
Filters (fanout < 1) have negative rank and go first, cheapest-per-row-removed first. Expanders go
last.

### 3.2 `exhaustive`: best-first search over partial plans

[dynprog.lsp](AmosNT_floq/lsp/dynprog.lsp) (Tore Risch, 1995; "C.f. Selinger et al. Assumes nested-loop
method of execution"). Despite the name and the reference, it is **not a bottom-up table of subsets**
like System R. It is a **uniform-cost (best-first) search**:

```
queue ← {(plan=[], bound=inputs, fanout=1, remaining=all)}  keyed by cost 0
loop:
    take all partial plans with the lowest cost key            (pop-cheapest-plans)
    drop "equivalent" ones                                    (different-plans)
    if one is complete → return it (it is the cheapest: costs only grow)
    if time is up      → fallback (below)
    for each plan, for each remaining executable predicate p:
        new cost = cost + fanout_so_far × cost(p)               (same formula as §2.2)
        new fanout = fanout_so_far × fanout(p)
        push the extended plan
```

- Compound predicates (OR, OPTIONAL) placed during the search are optimized recursively
  (`optimize-compound-predicate`).
- **Time limit:** `dynprogsort` (:192) stops after `_DYNPROG_MAX_TIME_` = 5, which its docstring says
  is seconds ([optimizer.lsp:388](AmosNT_floq/lsp/optimizer.lsp#L388)). It then applies the
  **fallback**, `dynprog-fallback-strategy`: take the first of the current best partial plans and
  finish it with `ranksort`. So a large query degrades to "optimal prefix + greedy tail".
- **Possible bug in pruning.** `different-plans` (dynprog.lsp:173, the "rewritten in iterative way"
  version) compares every later plan with `(car plans)`, the **first** plan, instead of the current
  one. The older recursive version, kept in a comment just above it, compared with the current plan.
  As written it can drop non-equivalent plans and keep duplicates. It only runs on plans that tie
  exactly on cost, so its effect is probably small, but it can cost optimality in those ties. This
  is inferred from reading the code, not confirmed by a run.
- Plans are "equivalent" when they have the same remaining predicates and the same bound set. Their
  current fanouts, which multiply all future costs, are not compared.

**Compared with your assignment.** Your `dynprogsort` in
[amos-query-optimization-assignment/](../amos-query-optimization/amos-query-optimization-assignment/)
was plugged in through `optmethod('exhaustive')` and replaced the one in this file. The helper it
called, **`simple-pred-cost`**, which returns `(cost . fanout)`, is defined only in
[randomopt.lsp:128](AmosNT_floq/lsp/randomopt.lsp#L128). The built-in optimizers use
`simple-pred-cost-bnd` ([optimizer.lsp:982](AmosNT_floq/lsp/optimizer.lsp#L982)), which returns a
list and handles cost hints and DTR the same way.

### 3.3 `randomopt`: iterative improvement + sequence heuristic

[randomopt.lsp](AmosNT_floq/lsp/randomopt.lsp) (Joakim Naes, 1993, master's thesis), for queries too
large for exhaustive search:

1. **Validity:** the initial order must be executable (`valid`), otherwise it raises "Query not
   executable" at once.
2. **Iterative Improvement** (`Iterative_Improvement`, :159): `_iino_` = 5 times, start from a random
   valid order (`random_state`), then do a **local descent** (`local_minimum`, :261). The descent
   repeatedly tries swapping **adjacent** predicates, accepting the first swap that keeps the plan
   executable and lowers the cost, until no swap helps. It keeps the best local minimum.
3. **Sequence Heuristic** (`IISH`, :179): `_shno_` = 5 times, take a **random walk** from the best
   state (`random_walk`), descend again, and keep the result if it is cheaper.

Details:
- **The seed is fixed** (`(randominit 73267)` at load *and* at the start of every `random-opt`), so the
  same query gives the same plan every time.
- Per-predicate costs are memoized per `(pred, bpat)` in `_fanout-ht_`.
- The state is kept on explicit stacks (`pushall`/`popall`) so that nested optimization is re-entrant.
- The two counts are set with `optlevel(x, y)`.

### 3.4 Which to use

| | ranksort | exhaustive | randomopt |
|---|---|---|---|
| Optimal? | No (greedy) | Yes, within the cost model and if it finishes in time | No (local search) |
| Growth | O(n²) cost evaluations | Exponential in the worst case | Fixed number of descents |
| Failure mode | Myopic: one early bad choice | 5 s limit → greedy tail | Local minima with adjacent swaps only |

All three share the same cost model. Where the cost model is wrong (§2.1), an "optimal" exhaustive
plan is only optimal for the wrong numbers.

---

## 4. Rewrite rules in practice

[REWRITE_RULES.md](REWRITE_RULES.md) lists every registration (44 in the tree, 8 in the standard
image). The mechanics are in [QUERY_COMPILER.md §6](QUERY_COMPILER.md#6-two-kinds-of-rewrite-rules).
What they look like in use:

**Rules active in the standard image:**

| Rule | Kind | What it does |
|---|---|---|
| `vref` ([tr-rewrites.lsp:20](AmosNT_floq/lsp/tr-rewrites.lsp#L20)) | TR | `(vector v v0 v1 …)` followed by `(vref v i x)` → substitute the `i`-th element directly |
| `makebag` ([tr-rewrites.lsp:48](AmosNT_floq/lsp/tr-rewrites.lsp#L48)) | TR | Fuses a makebag nested in a makebag |
| `euclid`, `minkowski` ([dist-based-index-rewrite2.lsp:245](AmosNT_floq/aqit/lsp/dist-based-index-rewrite2.lsp#L245)) | late TR (AQIT) | Fires when a conjunction has an inequality on a distance function and a stored function with an AQIT-capable index (e.g. XTREE, KDTREE); rewrites it to use the index (`distance-based-index-tester`, :190) |
| `mbtree` index ([mbindex.lsp:114](AmosNT_floq/lsp/mbindex.lsp#L114)) | index | `<`/`>` on a B-tree-indexed column → `mbt-select-range` ([STORAGE.md §7.4](STORAGE.md#74-how-a-range-index-gets-into-a-plan-mbtree)) |
| `rewriter 'x'` clauses ([TBR.lsp:434](AmosNT_floq/lsp/TBR.lsp#L434)) | TBR | Any multidirectional function can name a rewriter; `define-tbr` registers `rewrite-x` |
| index hook ([relation.lsp:79](AmosNT_floq/lsp/relation.lsp#L79)) | TBR | `addindex0` registers the index type's rewriter on the relation |

**Not everything built into the rewriter is a registered rule.** The equality unification in
`inferequals`, the `OR`→`IN` rewrite (`rewrite-or-by-in`) and partial evaluation are hard-coded in
[rewrite.lsp](AmosNT_floq/lsp/rewrite.lsp).

**The TR rule protocol** (`define-tr-rewriter`, [rewrite.lsp:431](AmosNT_floq/lsp/rewrite.lsp#L431)):
- `(test pred conjunction)`: non-`nil` means "applies". The value is passed on to the action.
- `(action pred conjunction test-value)`: returns the predicates that replace the conjunction.
- **At most one rule per function.** It is stored under the function's `tr-rewriter` property, and the
  generic function's rule is used if the resolvent has none.

**The TBR rule protocol** (`rewrite-preds`, [optimizer.lsp:1049](AmosNT_floq/lsp/optimizer.lsp#L1049)):
- The rewriter receives a `rewrite` struct: `this`, `bpat`, `bnd`, `rest`, `translated`.
- It returns one of:
  - `success`: it has set `translated` (and possibly changed `rest`);
  - `substitute`: "not me", so the normal `substbindadorned` is used;
  - `nil`: it failed, and the next rule is tried.
- Several rules per binding pattern are allowed. The first `success` wins.
- `mbindex.lsp` is the best short model to copy. Your
  [building-a-rewrite-rule.md](../amos-query-optimization/query-rewrite/building-a-rewrite-rule.md)
  builds one from scratch.

**Loose end:** `create-core-cluster-function`
([wrappers/datasource/core-cluster.lsp:53](AmosNT_floq/wrappers/datasource/core-cluster.lsp#L53))
registers `rewrite-extent`, which is defined only in the disabled `translator.lsp`. The relational
wrapper doesn't call this function ([BIGINTEGRATOR.md §7](BIGINTEGRATOR.md#7-loose-ends-found-in-the-code)),
and several unloaded wrappers (`Amos`, `amosexport`, `SparQL`, `sard`) still rely on it.

---

## 5. Reusing and recompiling plans

**Plans per binding pattern, compiled lazily.** A derived function's forward plan is compiled when it
is defined. Other binding patterns are compiled the first time they are needed
(`bpat-optimize-function`, [TBR.lsp:314](AmosNT_floq/lsp/TBR.lsp#L314)) and stored in a `tbr`. If
optimization fails, that `tbr` is marked `fail`, and `the-tbr-function` treats the pattern as
unavailable from then on.

**Inlining compiled plans.** When a query calls a function that already has a compiled plan for the
needed pattern, `pre-optimized-plan` ([optimizer.lsp:1347](AmosNT_floq/lsp/optimizer.lsp#L1347))
splices that plan in, if it is at most `*max-substitutable-size*` = 10 primitive predicates (:453).
Otherwise the call stays a call.

**Sub-plans.** [subplan.lsp](AmosNT_floq/lsp/subplan.lsp) can cut a section of a TBR conjunction into
its own transient function (`section-subplan`, `transform-section-subplan`). The plan then calls it
through the `INVOKE-PLAN` operator (`_invoke-plan_`, optimizer.lsp:458), which C executes with
`invoke_planfn` → `a_mapfunctionC` ([KERNEL.md §6](KERNEL.md#6-the-c--lisp-bridge)).

**Cached costs.** `exec-cost-of-fn` (:468) caches `(cost fanout)` on each function. `uncache-costs`
(:553) clears it for a function and, recursively, for every function that uses it. It is called when
an index is created or dropped ([STORAGE.md §3](STORAGE.md#3-stored-functions-and-their-relations)),
on recompilation (recompile.lsp:229) and by `reoptimize` (:569), so dependent costs are recomputed.
**Nothing in `lsp/` clears costs when data changes.** A cached cost therefore reflects the data at the
time it was computed. The binary kernel can't be checked for this.

**Recompilation** ([recompile.lsp](AmosNT_floq/lsp/recompile.lsp)):
- When a function is redefined, or a new resolvent is added to an overloaded function,
  `redefinefunction` (:241) and `recompile_depend` (:165) recompile the functions that depend on it
  (`recomp-dependent`: the transitive closure over `usedbyfunction`).
- Recompilation happens in dependency order (`recomp-order`).
- Some recompilations are **delayed**. `check-functions` (:198) forces the pending ones, and
  `init.lsp` calls it once after loading everything.
- During flattening, `needs-recomp?` triggers `recompile_depend` for a stale callee
  ([QUERY_COMPILER.md §4.2](QUERY_COMPILER.md#42-flattening-overload-resolution-and-type-checks-compileselect)).
- `recompile` (:212) recompiles one user function on demand.
