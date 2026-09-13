# AMOS II vs Polars: two query optimizers, two philosophies

A side-by-side comparison of the optimizer in **AMOS II** — a 1990s
main-memory functional mediator — and the optimizer in **Polars**, a 2020s
columnar analytics engine.

They are separated by thirty years, by a data model, and by an execution
strategy. The sharpest contrast, though, is narrower: **AMOS II prices whole
plans against each other and picks the cheapest; Polars rewrites a plan it
was given.** Almost everything else follows from that, and from the
representation choice underneath it.

Neither is a pure case, and the document is careful about this. AMOS II
applies rule-based rewrites *before* its cost-based search; Polars uses
estimates for a few targeted decisions. The difference is **where each draws
the line**, not that one estimates and the other doesn't.

PostgreSQL and MySQL appear as reference points, since they sit between the
two — algebra trees like Polars, global cost-based search like AMOS II.

> **Provenance.** AMOS II's *observed behaviour* comes from real runs
> recorded in
> [`amos-query-optimization-assignment/run-log.md`](amos-query-optimization-assignment/run-log.md)
> and [`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md).
> Polars' optimization passes are taken from its
> [official list](https://docs.pola.rs/user-guide/lazy/optimizations/), with
> further detail from the two blog posts under [Sources](#sources). Claims
> about **internal implementation** — how a counter is maintained, what is
> O(1) — are reasoning about how such systems are normally built, and are
> marked as such; they have not been verified against either codebase.
>
> An earlier draft of this document claimed Polars neither reorders joins
> nor estimates cardinality. The official list contradicts both. The claims
> have been corrected below — a reminder that the repo's rule of checking
> primary sources applies to comparisons as much as to AMOS II runs.
>
> A second round of corrections follows the TBR-rewrite work in
> [`query-rewrite/`](query-rewrite/). AMOS II's rule-based layer turns out to
> be larger than described here, it is **mutually exclusive** with the
> cost-based search, and AMOS II's inability to drive an index from a range
> is a property of the tested build rather than of the system.

## At a glance

| | AMOS II | Polars |
|---|---|---|
| Era / purpose | 1990s research mediator over heterogeneous sources | modern columnar DataFrame engine |
| Internal representation | **ObjectLog** — object-oriented Datalog | **algebra tree** — Scan / Filter / Join / … |
| Optimizer family | rule-based rewrites, then **cost-based search** (`optmethod('exhaustive')`) | rule-based rewrites, plus **targeted estimates** |
| Rule-based rewrite layer | simplification passes, **plus TBR-rewrite rules** — but those fire only under `ranksort` | the primary mechanism — eight passes, always on |
| Global cost model | yes — `(cost . fanout)` per predicate per binding pattern | **no** — no whole-plan cost function |
| Does it estimate? | yes — cardinality and fanout, for every predicate | yes, but narrowly: group-by strategy, join branch order |
| Statistics used | live cardinality, index uniqueness | Parquet row-group min/max, Hive paths, sortedness |
| Purpose of statistics | **compare candidate plans** | **skip data that can't match** |
| Join order | chosen by search over `n!` orderings, minimising cost | reordered to reduce **memory pressure** |
| Join algorithm | nested loop | hash, or sort-merge when sortedness is provable |
| Execution | tuple-at-a-time, main memory | vectorized columnar, parallel, streaming |
| Optimizes for | tuples visited | bytes read, memory pressure, parallel throughput |

Both are genuinely "query optimizers." They solve different problems.

## 1. Representation decides the job

This is the root difference; the rest is downstream of it.

| | ObjectLog (AMOS II) | Algebra tree (Polars, PostgreSQL, DuckDB, Spark) |
|---|---|---|
| Family | Datalog — declarative logic | relational algebra |
| Unit | predicate with variables | operator consuming and producing rows |
| Body | conjunction: `p(M,_V1) & q(M,_V2) & …` | tree: `Filter(Join(Scan, Scan))` |
| Is order meaningful? | **No** — conjunction commutes | **Yes** — the tree shape *is* the plan |
| Optimizer's job | **choose** an order | **rewrite** the tree |

An ObjectLog body is a set of predicates joined by `&`. Logical conjunction
commutes, so the written order carries no meaning — every permutation is the
same query. The optimizer is therefore handed a genuine **search problem**:
`n!` orderings to choose between. That is the problem `dynprogsort` solves.

A Polars `LazyFrame` is already a tree. `df.filter(...).join(...)` has
committed to a structure before the optimizer sees it. Its job is to
*transform* that tree into a better one — push this node below that one,
prune those columns. It does adjust join-branch order, but as a local
memory-driven decision rather than a priced search over whole plans.

### Directionality: why AMOS II needs binding patterns and Polars doesn't

In a logic language a predicate is a **relation**, not a function call, so
it can be evaluated in more than one direction depending on what is already
bound. `year(T, Y)` can run:

- `T → Y` — given a tournament, find its year
- `Y → T` — given a year, find the tournament

Same predicate, different access path, **different cost**. That is precisely
what a binding pattern like `(+ -)` encodes, and why `simple-pred-cost`
takes `bpat` as an argument at all — a cost is meaningless without a
direction.

Relational algebra has no such notion. A `Scan` produces rows; a `Filter`
consumes them. You cannot run a filter backwards. Direction is baked into
each operator by construction, so Polars never needs binding patterns, never
adorns operators `bf`/`fb`/`bb`, and never asks which direction to evaluate
in.

This also multiplies AMOS II's search space: each of the `n!` orderings
implies a *different set of binding patterns*, and therefore different costs
for the very same predicates.

### Why AMOS II chose Datalog

The lineage is the functional-mediator research tradition — the Litwin &
Risch paper in the assignment's references is titled *"Main Memory Oriented
Optimization of OO Queries Using Typed Datalog with Foreign Predicates."*
The choice buys two things that matter when mediating over heterogeneous
external sources: multi-directional predicates over wrapped foreign data,
and native recursion (transitive closure is trivial in Datalog; SQL needed
`WITH RECURSIVE` bolted on).

AMOS II is the unusual one here. Datalog-style representations survive in
program analysis (Soufflé, DDlog) and as the query language in Datomic, XTDB
and CozoDB — but for mainstream analytics engines, algebra trees won.

## 2. AMOS II's cost model — and Polars' absence of one

### What AMOS II computes

Two numbers per predicate, per binding pattern:

- **cost** — `2 × tuples visited`
- **fanout** — how many result tuples the predicate produces

Both come from `(simple-pred-cost pred bpat)`, returned as a dotted pair.
From a real run:

```lisp
(setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 1950))
(simple-pred-cost pred '(+ -))
=> (28 . 1.0)
```

`28 = 2 × 14`, so the stored function holds 14 tuples; fanout `1.0` because
a lookup by year yields one tournament. Plans accumulate these across an
ordering:

```
cost'   = cost + predcost × fanout
fanout' = fanout × predfanout
```

### Fanout errors compound; cost errors don't

`fanout` is a **multiplier on everything downstream**. A 10× fanout
underestimate in the *first* predicate makes every later predicate look 10×
cheaper than it is, and the search confidently picks a bad order. The same
error in the *last* predicate costs nothing — nothing follows it to be
scaled.

**Estimation accuracy matters in inverse proportion to depth.** This is why
optimizers everywhere obsess over the selectivity of the first few
operators.

### What Polars uses instead

Polars has **no whole-plan cost function**. Nothing assigns a number to a
candidate plan so it can be compared against an alternative — the step that
defines cost-based optimization, and the thing `dynprogsort` exists to do.

But it is not estimate-free. Its decisions come from three sources:

1. **Rules believed to be universally good** — push filters and projections
   toward the source, prune columns, eliminate common subplans, fold
   constants.
2. **Provable properties of the plan** — this column is known-sorted, this
   Parquet row group's min/max cannot contain a match, this Hive partition
   is irrelevant. Exact, never wrong.
3. **Targeted estimates for specific local decisions** — cardinality
   estimation to pick a group-by strategy, and join-branch ordering to
   reduce memory pressure.

Category 3 is the one an earlier draft of this document got wrong. Polars
*does* estimate. The distinction that survives is what the estimate is
*for*: Polars uses it to choose **how to execute one operator**, AMOS II
uses it to choose **which of n! plans to run at all**.

### Polars' optimization passes, and their AMOS II analogues

The [official list](https://docs.pola.rs/user-guide/lazy/optimizations/):

| Polars pass | What it does | AMOS II analogue |
|---|---|---|
| **Predicate pushdown** | apply filters as early as possible, at scan level | **both** — *emergent* under `exhaustive` (cheap selective predicates sort to the front because the cost model prices them that way); **rule-based** under `ranksort`, where TBR-rewrite rules fold predicates into an index access call |
| **Projection pushdown** | read only the columns needed, at scan level | **none** — no columns to prune; a stored function's tuples are its extent |
| **Slice pushdown** | load only the required slice; don't materialise sliced output | **none** in the plan model |
| **Common subplan elimination** | cache subtrees / file scans used by multiple subtrees | **none** in `dynprogsort` — it orders one conjunction |
| **Simplify expressions** | constant folding; swap expensive ops for cheaper ones | the **`Simplified`** stage in `pc()` output |
| **Join ordering** | estimate which join branches to run first, to reduce memory pressure | the **whole point** of `dynprogsort` — but minimising cost, not memory |
| **Type coercion** | coerce types so operations succeed on minimal memory | the **`Coerced`** stage in `pc()` output |
| **Cardinality estimation** | estimate cardinality to pick the group-by strategy | `simple-pred-cost`'s fanout — but used to order predicates, not to pick an operator |

Two things jump out of that table.

**First, AMOS II has rule-based passes too.** They are visible by name in
real `pc()` output — `Simplified`, `Normalized and simplified`, `Coerced`
all run *before* the cost-based reordering stage (`Decomposed (TBR)`). So
AMOS II is a hybrid as well: rules for simplification and type work, search
only for ordering.

**Second, the passes with no AMOS II analogue are all columnar or
file-format concerns** — projection pushdown, slice pushdown, common subplan
elimination. They exist because Polars reads columns from files; AMOS II
holds tuples in memory and has nothing to prune or cache. These aren't
things AMOS II *lacks* so much as problems it does not have.

### So both are hybrids — where does each draw the line?

```
AMOS II:  [ rules: simplify, normalize, coerce ] → [ COST-BASED SEARCH: ordering ]
Polars:   [ rules: pushdowns, CSE, simplify, coerce ] + [ local estimates: group-by, join branches ]
```

The line is drawn at **plan ordering**. AMOS II turns ordering into a global
search over `n!` alternatives, priced by a cost function. Polars treats
ordering either as a rule (push filters down, always) or as a local,
single-objective heuristic (which join branch first, to limit memory) — it
never enumerates whole plans and compares their costs.

### The third rule layer: TBR-rewrite rules

The diagram above is incomplete. Besides the simplification passes, AMOS II
has a rewrite mechanism that is **structurally the same thing Polars does**:
TBR-rewrite rules, documented in
[`query-rewrite/README.md`](query-rewrite/README.md).

A TBR rule pattern-matches a predicate, absorbs neighbouring predicates out
of the conjunction, and replaces them with a call to a specialised access
routine. The shipped example turns

    foo(i) ∧ i>1 ∧ i<=4

into a single B-tree range call plus a post-filter for what the index cannot
express. That is predicate pushdown in the Polars sense — recognise a
predicate the storage layer can serve natively, hand it over, filter the
remainder afterwards. No costing is involved; it fires on shape alone.

Crucially, **no ordering of predicates can produce this result.** The
cost-based search permutes a conjunction; a rewrite rule changes what the
conjunction *contains*. They are different powers, and AMOS II has both.

#### But not at the same time

`rewrite.txt` §3 restricts TBR rewrites to RANKSORT, and a controlled A/B
confirms it behaviourally — the same query fails under `ranksort` and
succeeds under `exhaustive`, because the rewrite fires in one and not the
other ([transcript](query-rewrite/README.md#test-switching-the-optimizer-switches-the-failure)).

| Optimizer | TBR-rewrite rules | Cost-based search |
|---|---|---|
| `ranksort` (default) | ✓ | ✗ — greedy heuristic only |
| `exhaustive` | ✗ | ✓ |

So the two mechanisms are **mutually exclusive**, which is a sharper
statement than "AMOS II is a hybrid." Enabling `dynprogsort` — the whole
point of the assignment — *disables* the layer that lets an index serve a
range. You choose Selinger-style search or Polars-style rewriting, not both.

Polars has no such constraint: its eight passes and its two local estimates
run together on every query. Whether AMOS II's restriction is fundamental or
an artifact of how the two paths were implemented is not stated in the
document.

### How Polars' two estimates are actually used

The official list names the two decisions but not the mechanism. The
standard reasoning behind each — *inferred, not cited*:

**Group-by strategy ← cardinality of the grouping key.** The question is how
many distinct groups there will be, because that decides the algorithm:

```python
df.group_by("country").agg(pl.col("sales").sum())   # ~200 groups
df.group_by("user_id").agg(pl.col("sales").sum())   # ~50,000,000 groups
```

| | Few groups (`country`) | Many groups (`user_id`) |
|---|---|---|
| Hash table | ~200 entries — fits in cache | 50M entries — thrashes memory |
| Parallel plan | each thread keeps a **local** table, merge at the end | **hash-partition first**, so each group lands in one thread |
| Why | merging 8 × 200 entries is trivial | merging 8 × 50M entries costs as much as the aggregation |

The crux is the merge step: per-thread hash tables cost `O(threads ×
groups)` to combine. Cheap for few groups, ruinous for many — so at high
cardinality you partition the input instead, and no merge is needed at all.

**Join branch order ← which side goes in memory.** A hash join *builds* one
side into a hash table and *probes* with the other. Peak memory is the build
side's size, so the rule is build the smaller side:

```python
big.join(small, on="id")     # big = 100M rows, small = 1,000 rows
```

Building on `big` holds 100M rows resident; building on `small` holds 1,000
and streams the rest past. Identical results, wildly different memory. With
chained joins it extends to which join runs first, since intermediates must
be held: if `a ⋈ b` yields 80M rows but `a ⋈ c` yields 5,000, doing the small
one first keeps the intermediate tiny.

Note the objective is **memory, not time** — a real departure from Selinger.
For an engine that must handle larger-than-RAM data, exceeding memory is a
*hard failure*, not merely slow, so peak memory is worth optimising
directly.

### The same estimate, a different objective function

`dynprogsort` already computes the number Polars uses for join ordering:
`oldfanout` *is* the intermediate result size at each step. The difference
is only how it is aggregated over the plan:

```lisp
; minimise total cost — what the assignment implements:
:cost (+ oldcost (* oldfanout predcost))    ; a SUM over the plan

; minimise peak memory would instead track:
;   max(oldfanout) across the plan          ; a MAX over the plan
```

Minimising a sum gives Selinger; minimising a max gives Polars' memory-driven
ordering. The two can disagree sharply — a cheapest-total-cost plan often
pushes one enormous intermediate through the middle.

This would make a sharp extension exercise: run `dynprogsort` twice on the
same query, once minimising summed cost and once minimising peak fanout, and
report whether the chosen ordering differs. It is a small change — swap the
`:cost` accumulation for a running max — and it demonstrates that "optimal"
means nothing until the objective is named.

### The word "statistics" means different things

This is a genuine source of confusion. Polars *does* read statistics — but
they serve a completely different purpose:

| | AMOS II statistics | Polars statistics |
|---|---|---|
| What | cardinality, distinct counts | Parquet row-group min/max, partition paths, sortedness |
| Used for | **pricing candidate plans** | **skipping data that cannot match** |
| Nature | approximate summaries | exact bounds and properties |
| If unhelpful | a bad plan is chosen | no skipping; the plan is still correct |

AMOS II's statistics answer *"which plan is cheapest?"* Polars' answer
*"can I avoid reading this block at all?"* — data skipping, not plan
costing.

#### The three Polars mechanisms, concretely

**Parquet row-group min/max.** A Parquet file is divided into row groups
(~128 MB or ~1M rows), and the footer holds per-row-group, per-column `min`,
`max` and `null_count`. For `filter(pl.col("year") > 2020)` the reader
checks the footer first:

```
Row group 0:  year min=2010  max=2014   → max < 2020, cannot match → SKIP
Row group 1:  year min=2015  max=2019   → SKIP
Row group 2:  year min=2020  max=2024   → must read
```

Two caveats decide whether this is powerful or worthless:

- **It depends entirely on clustering.** Sorted data gives each row group a
  narrow range and excellent skipping. Randomly ordered data gives every row
  group the full range — statistics present, technically correct, completely
  useless. Hence the standard advice to sort before writing Parquet.
- **It only works for order-comparable predicates.** `>`, `<`, `=`,
  `BETWEEN` can be tested against bounds; `str.contains(regex)` cannot, since
  no bound proves a regex won't match. This is exactly the wrinkle in
  [§5](#5-case-study-predicate-pushdown).

**Hive partition paths.** Column values encoded in directory names:

```
data/year=2023/month=01/part-0.parquet
data/year=2024/month=01/part-0.parquet
```

For `year == 2024`, the 2023 files are never opened — not even their
footers. The `year` and `month` columns are not stored in the files at all;
they are reconstructed from the paths. This yields a cost hierarchy where
each layer eliminates work for the one below:

| Technique | What it reads | Cost |
|---|---|---|
| Hive partition pruning | directory names | ~free |
| Row-group skipping | file footers | small |
| Reading data | column chunks | the real work |

**Sortedness.** A per-column flag, set because the plan contains a sort
(provable), the source declares it, or the user asserts it with
`set_sorted()`. It unlocks sort-merge join instead of hash join (no hash
table, far less memory), binary search instead of a scan, streaming group-by
(rows of a group are adjacent, so no hash table at all), and O(1)
`min`/`max`.

This one differs in kind: it is a **property**, not a summary — and it is
the one you can break. Asserting `set_sorted()` on unsorted data does not
merely slow the query, it produces **wrong answers**, because merge logic
assumes the ordering holds. That is the force behind the streaming-joins
post's insistence that sortedness must be known *to the optimizer*: the flag
is a promise you are required to keep.

#### What AMOS II has instead

| Polars mechanism | AMOS II equivalent |
|---|---|
| Parquet row-group min/max | **none** — no file format, no blocks; all data in memory |
| Hive partition pruning | **none** — no partitioning concept |
| Sortedness flag | partial — `mbtree` *is* an ordered structure |

That last row needs care. On the tested build, `mbtree` maintains order yet
serves `=` and **not** `>`/`<` (see
[`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md)) —
so AMOS II has the ordered structure and cannot exploit it for ranges,
precisely the case where Polars' min/max bounds are strongest.

**That is a build artifact, not a design property.** AMOS II was built to
drive an index from a range: `MBT-SELECT-RANGE` exists for exactly that, and
the rewrite rule targeting it is registered and does fire. What is missing on
this build is an implementation binding under one generic function — traced
in [`query-rewrite/README.md`](query-rewrite/README.md#why-mbtree-ranges-fail-on-this-build--resolved).

So the mirror-image framing holds for *this installation*, not for the
architecture. By design both systems exploit ordering for ranges; they differ
in where — Polars skips blocks it never reads, AMOS II selects an access
path.

## 3. Constraints beat statistics — in both systems

Not every number an optimizer uses is an estimate. **Constraints** are
declarations about all possible data: exact, free, and impossible to
falsify. **Statistics** are summaries of data as it currently is:
approximate, potentially stale, defeated by skew.

Both systems lean on constraints wherever they can.

**AMOS II** declares index uniqueness at creation time:

| Index kind | Fanout of an equality lookup | How known |
|---|---|---|
| `"unique"` | 1 | guaranteed by the schema — no data read |
| `"multiple"` | 0…n | must be estimated |

For a unique index, "how many tuples match this key" follows from the
index's *definition*. There is no distribution to be non-uniform about — a
unique key cannot be skewed. **Distribution only matters for `"multiple"`
indexes.**

**Polars** does the structurally identical thing with sortedness: it picks a
sort-merge join over a hash join only when the streaming engine is active,
the join is an equality or range join, and both columns are *known to be
sorted* — with the emphasis that this means **known to the optimizer, not
merely known to you**. Sortedness is a property the planner can *prove* from
the plan, so it is used with certainty.

Same move, different property: where something can be proven, no estimation
is needed. Estimation is the fallback when it can't. (PostgreSQL does this
too — a unique index turns an equality selectivity estimate into a
certainty.)

## 4. Where AMOS II's estimates break

Polars' estimates are confined to two local choices — group-by strategy and
join-branch order — so a bad estimate degrades one operator or costs some
memory. AMOS II's estimates decide *the entire plan*, so a bad one is
unbounded: it picks the wrong ordering, and everything downstream inherits
it. Two specific places let that happen.

### Skew defeats `rows ÷ distinct`

For a `"multiple"` index with no histogram, the only available estimate is
the average. It is correct exactly when the data is uniform:

| Predicate | Reality | Averaged estimate |
|---|---|---|
| `year(tournament)` — unique | exactly 1 tournament per year | exact, 1 |
| `played_in` reversed — tournament → matches | 22 matches in 1950, 64 in 2014 | ~35 for both — wrong twice |

A single number cannot describe a spread. No amount of *counting* fixes
this; it needs a *histogram*, which AMOS II does not have.

### `>` and `<` are cruder still

- **Equality** with the result side free is a **generator** — it produces
  tuples, and its fanout feeds the multiplication.
- **Ranges do not drive an index on this build.** `mbtree` serves `=` but
  not `>`/`<` (verified — see
  [`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md)),
  so a range predicate becomes a boolean filter with both arguments bound:

  ```
  (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V2 100000)
  ```

  Its fanout is a pure selectivity guess — *what fraction survives?* — and
  with no histogram it can only be a fixed constant.

So on this build AMOS II sidesteps range-selectivity estimation by never
letting a range choose an access path, filtering afterwards instead.

Note this is a consequence of the missing `MBT-SELECT-RANGE` binding, not of
the design. Had the rewrite been able to complete, a range *would* select an
access path — and AMOS II would then need exactly the range-selectivity
estimate it currently avoids. The gap in the cost model is hidden by the gap
in the access path.

Polars, by contrast, finds ranges *easier* than equality on the skipping
side: min/max row-group statistics are exactly range bounds, so `col > 100`
prunes blocks that an equality on an unsorted column could not.

### One thing AMOS II structurally cannot get wrong

Disk systems cannot read statistics during optimization: learning "how many
rows, how distributed" means scanning or sampling pages — I/O of the same
order as running the query. So it is done occasionally (`ANALYZE`,
autovacuum, InnoDB's random B-tree dives) and **cached in the catalog**. A
cache not invalidated on write is exactly what "stale" means, and the
classic production failure follows: table grows 100×, nobody re-analyzes,
planner still believes 1,000 rows, picks a nested loop, query goes from
seconds to hours.

In main memory the economics invert. Cardinality is a property of the data
structure — a counter — so reading it is O(1) while running the query is
O(n). *Because fetching it is free, there is no reason to cache it*, so the
optimizer reads the live value at plan time. No snapshot exists, so nothing
can drift. **The staleness bug requires a cache; AMOS II needs none.**

Three qualifications:

1. O(1) is not free — it is an O(1) increment on every insert and delete,
   paid forever so the read is cheap. *(Reasoning, not verified.)*
2. "Entry count" and "distinct key count" coincide only for unique indexes;
   non-unique ones need two maintained counters to get both in O(1).
   *(Reasoning, not verified.)*
3. The immunity comes from the cost model being *simple*, not from main
   memory as such. A main-memory engine maintaining histograms would face
   the same tradeoff and end up caching again.

AMOS II cannot have stale **counts**. It can still be wrong about
**distributions**.

## 5. Case study: predicate pushdown

The sharpest point of contact between the two designs, because both arrive
at the same answer by opposite routes.
  
**Polars' rule:** *always* push filters as close to the source as possible.

**AMOS II believes nothing.** When `dynprogsort` places `year(_V2)=1950`
first, it is because cost 28 × fanout 1 beat every alternative ordering. It
reaches pushdown as a **result of arithmetic**, not as a rule — and could in
principle *decline* to push something down when the numbers say otherwise,
which a rule-based optimizer structurally cannot.

Note that AMOS II's own default mode, `ranksort`, is much closer to Polars
in spirit: heuristic, no search. Exhaustive search is the exception, not the
norm — which is why implementing it was an exercise in the first place.

### When the rule is *illegal*

These are correctness guards, not heuristic failures. Any optimizer must
refuse them:

- **Outer joins.** `LEFT JOIN … WHERE right.x > 5` differs from filtering
  the right side before the join: the first discards null-extended rows, the
  second keeps them. Pushing to the null-producing side silently converts an
  outer join to an inner one.
- **Aggregation.** A predicate on an aggregate (`HAVING sum(x) > 10`) cannot
  go below the group-by; one on a grouping key can.
- **Window functions.** Filtering first changes the population the window is
  computed over, so `rank()` returns different values.
- **`limit` / `slice`.** Filter-then-take and take-then-filter select
  different rows.
- **Non-deterministic expressions** — randomness, row position.

### When the rule is legal but *wrong*

The belief assumes filters are cheap. It inverts when an **expensive**
filter is pushed past a **selective** operator:

```python
df.lazy()
  .join(small_lookup, on="id")                     # keeps 1% of rows
  .filter(pl.col("text").str.contains(r"<expensive regex>"))
```

With 10,000,000 input rows, a join keeping 1%, and a regex passing 50% of
what it sees:

| | Plan A — filter above join | Plan B — filter pushed below |
|---|---|---|
| First step | join: 10M probes | regex: **10M evaluations** |
| Second step | regex: **100K evaluations** | join: 5M probes |
| If one regex ≈ 100 × one probe | `10M + 100K×100` ≈ **20M** | `10M×100 + 5M` ≈ **1,005M** |

Both return the same 50,000 rows; Plan B is roughly **50× worse**. Pushdown
bought a 2× reduction on the cheap operation and paid a 100× increase on the
expensive one.

Precisely — pushing a filter past an operator changes its evaluation count
from *rows surviving that operator* to *all rows*:

```
penalty = filter_cost   × (N_all − N_surviving_downstream_op)
benefit = operator_cost × (N_all − N_passing_filter)
```

The **penalty** is driven by the selectivity of the operator being pushed
past; the **benefit** by the selectivity of the filter itself. Note the
filter's own selectivity does *not* reduce its own cost — once pushed down
it runs on every row regardless.

**Why the rule wins anyway.** Swap in a plain comparison
(`pl.col("amount") > 100`) and Plan A ≈ 10.1M versus Plan B ≈ 15M — same
order of magnitude, and Plan B wins outright if the filter is more selective
than the join. Since nearly all real filters are cheap comparisons, "always
push down" is right nearly always. That is what makes it both a good rule
and a dangerous one.

**A Polars-specific wrinkle:** pushing a filter into the *scan* normally
earns a bonus — Parquet row-group skipping, so the data is never read. But a
regex cannot drive min/max skipping, so `str.contains` takes the cost
increase without the compensating benefit.

**How each family copes.** PostgreSQL attaches a `COST` attribute to
functions and weighs it against estimated selectivity, so
`CREATE FUNCTION … COST 10000` tells the planner not to evaluate eagerly.
Polars has no per-expression cost attribute, so it cannot distinguish a
regex from a column comparison — its cardinality estimation answers "how
many rows?", never "how expensive is this expression?". The escape hatch is
for the *user* to supply the missing judgement — restructure the query, or
disable the pass (`collect(predicate_pushdown=False)`,
`no_optimization=True`).

`dynprogsort` needs neither, because its cost formula already *is* this
calculation:

```lisp
:cost (+ oldcost (* oldfanout predcost))
```

`oldfanout` is exactly `N_surviving_downstream_op` — how many times the
predicate will be invoked at that position. Placed late, an expensive
predicate has a small per-call cost and a large multiplier; placed early, it
is an unbound generator with a large `predcost` and a multiplier of 1. The
search prices both. The rule's inversion cannot occur.

The standing caveat: right *shape* is not right *numbers*. Whether
`simple-pred-cost` reports a realistic cost for a **foreign** predicate
depends on whether that function carries a cost annotation.

That annotation mechanism is now identified. `rewrite.txt` §3.1 attaches a
cost function **per binding pattern**, alongside the implementation and the
rewriter:

```sql
create function fie(integer x)->real y as multidirectional
        ("bf" foreign "fiebf" cost "fiebfcost" rewriter "fiebf")
        ("fb" foreign "fiefb" cost "fiefbcost" rewriter "fiefb");
```

**The default is now measured, and it is a flat constant.** `bar_range` in
[`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md)
is a foreign function declared with **no** `cost` clause:

```lisp
(setq bp (list (getfunctionnamed 'integer.integer.bar_range->integer.integer)
               2 3 'x 'y))
(simple-pred-cost bp '(- - + +))
=> (100 . 100)
```

Compare stored functions, where the numbers are derived from the data:

```lisp
(setq bp2 (list (getfunctionnamed 'p_integer.bar->integer) 'x 'y))
(simple-pred-cost bp2 '(+ +))
=> (6 . 3)
```

| Predicate | `(cost . fanout)` | Where the numbers come from |
|---|---|---|
| `tournament.year`, 14 tuples | `(28 . 1.0)` | `2 × 14`; fanout 1.0 from index uniqueness |
| `bar`, 3 tuples | `(6 . 3)` | `2 × 3`; fanout 3 — the whole extent, both sides free |
| `bar_range`, unannotated foreign | `(100 . 100)` | neither |

Both stored functions track their actual size: change the row count and the
numbers change. `bar_range` returns **at most three tuples** — it scans the
same `bar` — and is priced at 100. The number is not a measurement of
anything.

*(Inference, on one sample: that `(100 . 100)` is a fixed default rather than
a computation. A second unannotated foreign function returning the same pair
would confirm it. Note the fanout is an integer here where `tournament.year`
gave a float, so fanout type carries no information either way.)*

**This materially qualifies the argument above.** The claim that
`dynprogsort`'s formula makes the pushdown inversion structurally impossible
holds only while the cost inputs are real. For an unannotated foreign
predicate, AMOS II is in precisely the position it was contrasted against:

- It cannot tell an expensive foreign predicate from a cheap one — every one
  is priced at 100, exactly the gap Polars has with expressions.
- The fanout is worse than the cost. `bar_range(2,3)` returns at most three
  tuples; the optimizer believes 100. Per the compounding rule above, a
  fanout error in an early predicate scales *everything* after it.

So the cost model's advantage is real but **conditional on annotation**. A
foreign function with a proper `cost` function gets priced honestly; one
without is a confident guess wearing the costume of a measurement — arguably
worse than Polars' position, which at least does not claim to have priced
anything.

## 6. Execution models, and why the cost models differ

The optimizers differ partly because what they are optimizing differs.

| | AMOS II | Polars |
|---|---|---|
| Granularity | tuple-at-a-time | vectorized, columnar batches |
| Join | nested loop over ObjectLog predicates | hash join; sort-merge when provably sorted |
| Data location | main memory | memory, with streaming/out-of-core for larger-than-RAM |
| Parallelism | none in the plan model | multi-threaded, morsel-driven |
| Dominant cost | tuples visited | bytes read, memory pressure, thread utilisation |

AMOS II's `2 × tuples visited` is honest *because* execution is
tuple-at-a-time nested-loop interpretation in memory. Tuples visited really
is the cost.

That formula would be close to meaningless for Polars, where the same row
count can cost wildly different amounts depending on how many columns are
touched, whether data is read from disk or S3, whether the operation
vectorizes, and how well it parallelises. A single-number-per-operator cost
model is a much harder thing to build for a columnar parallel engine — which
is part of why rule-based optimization plus exact data-skipping is a
defensible choice there rather than merely a missing feature.

## 7. What each could take from the other

**Polars could extend estimation from operators to plans.** It already
estimates cardinality — for group-by strategy — and already reorders join
branches. What it lacks is a **per-expression cost attribute**, which is
exactly what would fix the pushdown inversion: knowing a regex is 100× a
comparison is what lets an optimizer decline to push it. The machinery for
whole-plan costing is closer than the "no cost model" framing suggests; the
missing pieces are expression costs and a comparison step.

On that specific feature the three systems rank the other way round from the
overall comparison:

| System | Cost annotation granularity |
|---|---|
| Polars | none |
| PostgreSQL | per function (`CREATE FUNCTION … COST 10000`) |
| AMOS II | **per function, per binding pattern** (`cost "fiebfcost"`) |

AMOS II's is the finest of the three, and necessarily so: a multi-directional
predicate has a different cost in each direction, so one number per function
would be meaningless.

**AMOS II could use exact metadata.** It estimates where Polars proves.
Histograms would fix its skew blindness on `"multiple"` indexes, and range
statistics would let `>`/`<` drive access paths rather than degrading into
post-filters — a gap Polars does not have, since min/max bounds *are* range
bounds.

**Neither objective is the whole story.** AMOS II minimises tuples visited.
Polars' join ordering minimises **memory pressure** — a different objective
entirely, and a rational one for an engine that must handle
larger-than-memory data. A plan can be cheap in tuple visits and still
out-of-memory. Real systems optimise multi-objective; the assignment's cost
model is single-objective because main memory makes the others moot.

The deeper observation: **every optimizer prefers a provable property to an
estimate** — uniqueness, sortedness, min/max bounds — and estimates only for
what cannot be proven. Polars maximises the provable category and keeps
estimation local; AMOS II accepts global estimation to buy a search the
provable category alone could not support.

## Summary

- **Representation decides the job.** ObjectLog's commutative conjunction
  leaves predicate order undetermined, creating a search problem and
  requiring binding patterns for multi-directional predicates. Polars'
  algebra tree fixes order structurally, so its optimizer transforms rather
  than searches.
- **Both are hybrids; the line is drawn at plan ordering.** AMOS II runs
  rule-based passes first — `Simplified`, `Normalized and simplified`,
  `Coerced` are visible stages in real `pc()` output — and reserves
  cost-based search for predicate ordering. Polars rewrites by rule and
  estimates only for two local decisions (group-by strategy, join-branch
  order). Neither is pure.
- **AMOS II's two mechanisms are mutually exclusive.** Besides the
  simplification passes it has TBR-rewrite rules, which fold predicates into
  specialised access calls exactly as Polars' pushdown does — something no
  reordering can achieve. But they fire only under `ranksort`, so enabling
  `dynprogsort` disables them. You get Selinger-style search or Polars-style
  rewriting, not both. Polars runs all its passes together, always.
- **The real distinction is what an estimate is *for*.** Polars estimates to
  choose **how to execute one operator**; AMOS II estimates to choose
  **which of n! plans to run**. Only the second needs a whole-plan cost
  function, and only the second can be globally wrong.
- **"Statistics" is an overloaded word.** AMOS II's price candidate plans
  and are approximate; Polars' Parquet min/max bounds skip unreadable data
  and are exact.
- **Objectives differ, not just methods.** AMOS II minimises tuples visited;
  Polars' join ordering minimises memory pressure. Formally that is a **sum**
  over the plan versus a **max** over it — and `dynprogsort` already computes
  the number needed for both, since `oldfanout` *is* the intermediate size. A
  plan can be cheap in total cost and still run out of memory.
- **The two systems look like mirror images on ranges — but only on this
  build.** Polars finds `>`/`<` *easier* than equality on the skipping side,
  because min/max bounds are literally range bounds. On the tested AMOS II
  release a range degrades into a post-filter, since `mbtree` serves `=` but
  not `>`/`<`. That is a missing implementation binding, not a design choice:
  `MBT-SELECT-RANGE` and its rewrite rule both exist, and the rule fires. By
  design both systems exploit ordering for ranges.
- **Cost annotations run the other way.** Polars has none, PostgreSQL has one
  per function, AMOS II has one **per function per binding pattern** — the
  finest of the three, because a multi-directional predicate costs differently
  in each direction. But the annotation must actually be written: an
  unannotated foreign function prices at a flat `(100 . 100)` regardless of
  what it does, so the cost model's advantage is conditional on someone
  supplying the number.
- **Constraints beat statistics in both.** Uniqueness in AMOS II,
  provable sortedness in Polars — where a property can be proven, no
  estimate is needed.
- **A rule fails when its assumption inverts, and cannot notice.** "Always
  push filters down" assumes cheap filters; an expensive filter pushed past
  a selective operator can be orders of magnitude slower. A cost model
  agrees with the rule in the common case and disagrees when warranted —
  which is the entire argument for paying for the search.
- **AMOS II's risk is confined to `"multiple"` indexes and `>`/`<`
  filters**, and fanout errors matter most in the earliest predicates,
  because fanout multiplies everything after it.

## Sources

- AMOS II behaviour: real transcripts in
  [`amos-query-optimization-assignment/run-log.md`](amos-query-optimization-assignment/run-log.md)
  and [`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md).
- Cost model and dynamic programming algorithm: `Ex-Query optimization in
  AMOS2.pdf` (Linköping lab instruction), summarised in
  [`amos-query-optimization-assignment/README.md`](amos-query-optimization-assignment/README.md).
- W. Litwin and T. Risch, *Main Memory Oriented Optimization of OO Queries
  Using Typed Datalog with Foreign Predicates*, IEEE TKDE 4(6), 1992.
- TBR-rewrite rules, and a worked construction of one:
  [`query-rewrite/README.md`](query-rewrite/README.md) and
  [`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md).
- Polars' official list of optimization passes:
  <https://docs.pola.rs/user-guide/lazy/optimizations/>
- Polars predicate pushdown and data skipping:
  <https://pola.rs/posts/predicate-pushdown-query-optimizer/>
- Polars streaming joins and join-algorithm selection:
  <https://pola.rs/posts/streaming-joins/>
- P. G. Selinger et al., *Access Path Selection in a Relational Database
  Management System*, ACM SIGMOD 1979 — the origin of cost-based join
  enumeration.
