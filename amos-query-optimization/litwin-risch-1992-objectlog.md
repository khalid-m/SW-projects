# Litwin & Risch 1992 — the paper this system came from

Notes on **"Main Memory Oriented Optimization of OO Queries using Typed
Datalog with Foreign Predicates"**, Witold Litwin (Université Paris Dauphine)
and Tore Risch (Linköping University), *IEEE Transactions on Knowledge and
Data Engineering* **4**(6), December 1992.

Local copy: [`../Amos-II-docs/papers/OO-query-optimization-92.pdf`](../Amos-II-docs/papers/OO-query-optimization-92.pdf)

This is the paper cited throughout this repo, and it is the **primary source**
for most of the machinery the other documents here explore empirically:
ObjectLog, TR and TBR predicates, binding patterns, the cost-and-fanout model,
multi-directional foreign predicates, and the ranking heuristic that
`optmethod('ranksort')` is named after.

The system it describes is **WS-IRIS** (Workstation IRIS), an HP Labs
prototype and the direct ancestor of AMOS II. Its query language is
**WS-OSQL**, a dialect of IRIS's OSQL.

> **Extraction note.** This PDF is a 1992 TeX document with LZW streams and
> Type3 bitmap fonts; no text layer survives cleanly. The text was recovered
> by decoding the streams and re-joining words against a dictionary, so
> quotations below are faithful in substance but may differ from the original
> in spacing or hyphenation. Figure and page numbers refer to the paper.

## The thesis in one line

Main-memory residency is **necessary but not sufficient**. Without a good
optimizer, an in-memory database can be slower than a disk-based one.

The paper's own headline measurement, on `GrandSParentGrossIncome` over
10,000 objects (Fig. 16):

| Optimization | Time |
|---|---|
| Full (rule reordering + type-check removal) | **1.1 ms** |
| Rule reordering only | 2.6 ms |
| Type-check removal but **no rule reordering** | **13.3 minutes** |

Roughly a **700,000×** difference, on data that fits in memory either way.
Rule reordering is doing nearly all the work; type-check removal contributes a
constant factor of about 2.

The authors are explicit about the implication: *"without effective
optimization the system would be too slow for many applications, despite its
MM implementation."*

## Why Datalog rather than relational algebra

§1 identifies two contemporary approaches to OO query optimization — process
the object model with a relational engine, or define a dedicated OO algebra —
and rejects both. Datalog is chosen because its expressive power exceeds
relational languages (notably recursion) and its optimization principles were
already understood.

But pure Datalog lacks update semantics, typing and OID management. Hence
**ObjectLog**, described in §2.3 as a generalization of Datalog and LDL with:

- predicate arguments that are **objects** in a type hierarchy;
- update semantics preserving type integrity, which lets the optimizer *skip*
  dynamic type checks;
- **overloading on argument types** — each variant is a resolvent;
- **overloading on binding patterns** — which arguments are bound or free;
- **multi-way foreign predicates** implemented in "C, Lisp, or IPL";
- second-order predicates, used for late binding and recursion.

## TR and TBR — the acronyms, from the source

[`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md)
records TR and TBR as *inferred* expansions, since `rewrite.txt` never spells
them out. **The paper states them directly** (§2.3):

> Predicates can be overloaded on the types of their arguments. We call
> corresponding resolvent a **Type Resolved (TR)** predicate.
>
> Predicates can be further overloaded on the binding patterns of their
> arguments, i.e. on which arguments are bound or free when the predicate is
> called. We call each corresponding resolvent a **Type and Binding Pattern
> Resolved (TBR)** predicate.

So the inference in this repo was right, and is no longer an inference. There
is also a third, earlier stage — **TA, Type Adorned** — produced by annotating
a function name with its signature types before overload resolution.

## The compilation pipeline (§3, Fig. 2)

```
WS-OSQL function or query
      ↓  Flattener            remove nested calls; introduce _v1, _v2 …
      ↓  Type Checker         TA resolvents → overload resolution → type checks
      ↓  ObjectLog Generator  TA → TR program (facts, rules, foreign predicates)
      ↓  ObjectLog Optimizer  TR → TBR program (reordered, binding-adorned)
      ↓  ObjectLog Interpreter
```

Every stage name in this pipeline is visible in real `pc()` and `objlog()`
output on a modern build — see
[`amos-query-optimization-assignment/run-log.md`](amos-query-optimization-assignment/run-log.md).

**Flattening** (§3.1) introduces an intermediate variable per nested call.
`GrossIncome(p)` becomes

```
_v1 = Income(p) and _v2 = Bonus(p) and gi = Plus(_v1,_v2)
```

which is exactly the `_V1`/`_V2` variable naming seen in every plan this repo
has captured, thirty years later.

**Stored functions become TR facts; derived functions become TR rules; foreign
functions become TR foreign predicates** (§3.3). That is the origin of the
`P_…` predicate functions that TBR-rewrite rules attach to.

**The forward direction is the default** (§3.4): *"The function is optimized
for execution in the forward direction where arguments are known and results
computed… Functions can nevertheless also be used inversely, in which case the
optimizer will generate different TBR predicates."* This is the behaviour
[`CLAUDE.md`](CLAUDE.md) records as a recurring gotcha — `pc()` shows a
function's own declared direction, and inspecting another requires wrapping
the query in a new function.

## The cost model (§4.2.2)

Two estimates per TBR predicate:

| | Definition |
|---|---|
| **C_P** | execution cost — *the number of visited tuples*, given the input tuple is bound |
| **F_P** | fanout — estimated number of output tuples for one input tuple |

The total cost of a conjunction of literals `P₁…Pₙ` in a chosen order:

```
        n         i-1
  C =   Σ  ( C_Pi  Π  F_Pj )
       i=1        j=1
```

Each predicate's cost is multiplied by the fanout of everything before it.
This is precisely the accumulation implemented in the `dynprogsort` exercise:

```lisp
:cost   (+ oldcost (* oldfanout predcost))
:fanout (* oldfanout predfanout)
```

### Where `ranksort` gets its name

The paper notes that exhaustive optimizers take exponential time in the number
of literals, which *"proves inconvenient for WS-OSQL"*. The **default is a
heuristic producing query plans in quadratic time** — and it works by ranking:

```
  R_Pi = (F_Pi − 1) / C_Pi
```

At each step, choose the executable literal with the **minimum rank**, then
recompute. The stated motivation: repeatedly minimising `R` also minimises the
total cost `C`.

That formula is where the name `optmethod('ranksort')` comes from. The paper
also refers in passing to *"the heuristic or the exhaustive optimization
algorithm, whichever is used"*, so the exhaustive alternative — the one the
`dynprogsort` exercise implements — was present from the start.

### Default cost parameters

Used before a database is populated (§4.2.2). The system distinguishes unique
indexes, non-unique indexes, and unindexed inputs:

| Case | F_P | C_P |
|---|---|---|
| input tuple has a **unique** index | 1 | = F_P |
| input tuple has a **non-unique** index | 2 | = F_P |
| **unindexed** | 4 | 100 — the whole table is scanned |
| **foreign predicate** | **1** | **1** |

Default assumed size of a stored predicate: **100 tuples**.

The rationale given for the foreign-predicate default is candid: *"assuming
that they are cheap to execute and return a single result tuple."*

**This diverges from the tested build.** A foreign function declared with no
cost annotation prices at `(100 . 100)` on `AmosNT_floq` (Release 16 v11), not
`(1 . 1)` — see
[`cost-based-vs-rule-based-optimization.md`](cost-based-vs-rule-based-optimization.md).
Whether the default was changed deliberately in the intervening decades is not
established. Either way the paper's own framing stands: the number is an
assumption, not a measurement.

### Cost hints

§4.2.2 also describes the escape hatch:

> The DBA can provide cost hints for each TBR predicate, which override
> default assumptions about C_P and F_P. Hints are particularly useful for
> evaluating foreign predicates.

Hints are supplied as a WS-OSQL function returning the two estimates. This is
the `cost "fiebfcost"` clause in `rewrite.txt` §3.1's multidirectional
declaration syntax — a **per-binding-pattern** cost annotation, finer-grained
than PostgreSQL's per-function `COST`.

The worked example is instructive: `typesof^bf` (given an object, find its
type) is nearly free, because a pointer to an object's types is stored in the
OID itself; `typesof^fb` (given a type, find its objects) costs time
proportional to the number of objects of that type. Same predicate, opposite
directions, wildly different cost — which is why a cost estimate is meaningless
without a binding pattern, and why `simple-pred-cost` takes `bpat` as an
argument.

## Multi-directional foreign predicates (§5)

The feature the authors single out as distinguishing WS-IRIS: *"Unlike other
OO systems we know of, WS-IRIS optimizes multi-way foreign function calls,
i.e. where only the result of the function is known and the system finds the
corresponding argument(s)."*

One TR foreign predicate `P` has a set **S(P)** of implemented TBR resolvents,
one per binding pattern. For arithmetic:

```
S(plus)  = { plus^bbf, plus^bf b, plus^f bb }
S(times) = { times^bbf, times^bf b, times^f bb }
```

Footnote 14 describes how such predicates return results:

> Foreign predicates … are defined as **generators** that call a system
> provided C function, **emit**, for each result of a set valued foreign
> predicate. The generator method avoids materializing the result set, which
> saves MM usage significantly.

`emit` is the direct ancestor of `a_emit` in the C interface and
**`osql-result`** in the ALisp one — see
[`lisp-foreign-functions.md`](lisp-foreign-functions.md). The "avoids
materializing the result set" rationale explains why a Lisp foreign function
calls `osql-result` once per tuple rather than returning a list.

### Reordering for safety

A TBR rule referring to an unimplemented TBR predicate is **unsafe** — not
merely slow, but unexecutable. Fig. 13 shows such a rule for `ftemp`, blocked
because `plus^bf f` does not exist. Reordering fixes it: the optimizer must
find an order in which every literal's binding pattern is implemented.

That is the same failure this repo hit from the other direction. A TBR-rewrite
rule returning `NIL` leaves a predicate untranslated, and the query fails with
*"Query not executable … Unbound variables: (X)"* — recorded in
[`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md)
Step 1. Safety is a property of the whole reordered rule, not of one predicate.

### Constraint inferencing

The elegant consequence (§5.1, Fig. 12). Define Fahrenheit→Celsius once:

```sql
create function ftoc(Real f) -> Real c
  as select Div(Times(Minus(f,32.),5.),9.);
```

Because `Plus` and `Times` are multi-directional, the system can **infer the
inverse**. Given a stored Celsius temperature, `ftemp` runs `ftoc` backwards:

```sql
create function ftemp(Person p) -> Real f
  as select f where ftoc(f) = ctemp(p);
```

Likewise `Minus` and `Div` are *derived* functions defined by inverting `Plus`
and `Times`, rather than separate foreign implementations. Without this, the
user would have to write both directions and choose between them per query.

### The completion algorithm

Not every binding pattern needs implementing. A TBR predicate `P^p₁…pₙ`
**covers** `P^q₁…qₙ` when for every position either `pᵢ = qᵢ` or `qᵢ = b` —
informally, the cover has *fewer bindings*. So `plus^bbf` covers `plus^bbb`,
and the optimizer rewrites

```
plus^bbb(1,2,3)   →   plus^bbf(1,2,V1) & eq(V1,3)
```

computing the sum and then testing it. This is a genuine rewrite rule in the
same family as the TBR-rewrite rules of `rewrite.txt` — absorb a predicate,
emit a call plus a compensating test.

§5.3 then raises the question of a **minimal S(P)**, and answers it with a
caution: a covered predicate can be *much* faster than its cover, in which case
implement it anyway. `typesof^ff` covers every binary pattern but is
prohibitively expensive on a large database, so `typesof^bf` and `typesof^fb`
were implemented separately with cost functions attached. `typesof^bb` was
*not* implemented — no version significantly faster than its cover could be
found.

That is a design principle worth extracting: **implement a binding pattern when
it beats its cover, not merely because it is expressible.**

## Type checking and late binding (§4.1)

Type checks are added per variable and then removed where the type system
already guarantees them. The **Type Check Removal** rule: if a variable's
declared type is the argument's type or a supertype of it, the check is
redundant, because referential integrity constrains stored functions and type
checking constrains derived ones.

In the running example every `TypesOf` call turns out removable except one —
`SParent` must check that a `Parent` result is really a `Student`, since
`Parent` returns the more general `Person`.

**Late binding** is used only when semantically necessary, because it defeats
rule substitution and therefore global optimization. A generic TBR predicate on
the universal type `Object` is generated per overloaded function, implemented
as a call to the second-order foreign predicate `apply`, which resolves the
type at run time.

## Recursion (§5.4)

The flattener detects recursive functions and routes them through `Apply`,
compiled to the TR predicate `apply(p, a₁…aₙ, r₁…rₘ)` where `p` is the
recursive TBR predicate. Since ObjectLog is evaluated top-down, **left
recursion would be unsafe** — `apply` transforms such calls into right
recursion, which is safe unless there are circularities in the data or the
definition. The paper notes those cases are *not* detected, and would need
memoing or a bottom-up evaluation.

Measured: a recursive `ancestor` function returning six ancestors runs in
~4.3 ms, constant across 100 / 1,000 / 10,000 objects.

## Performance results (§6)

The OO1 benchmark (20,000 parts, 60,000 connections), warm, fast-path
interfaces:

| Measure | WS-IRIS | 4 OODBs | RDBMS |
|---|---|---|---|
| Lookup (s) | 0.07 | 0.03 – 1.1 | 19 |
| Traverse (s) | 0.3 | 0.1 – 1.2 | 84 |
| Insert (s) | 0.4 | 1.0 – 3.7 | 20 |
| **L+T+I (s)** | **0.8** | 3.2 – 6 | 123 |

Roughly 4× the other OODBs overall — attributed to updates not needing to be
committed to disk — and over 150× the relational system.

The claimed significance is not raw speed but that WS-IRIS achieves it *while*
offering a relationally complete declarative language; the OODBs it was
measured against provided navigational access only.

## What this paper settles for this repo

| Question | Answer from the paper |
|---|---|
| What do TR / TBR stand for? | Type Resolved / Type and Binding Pattern Resolved — §2.3, previously inferred here |
| Where does `ranksort` get its name? | The rank formula `R = (F−1)/C`, §4.2.2 |
| Why does cost need a binding pattern? | `typesof^bf` is free, `typesof^fb` is linear — same predicate, opposite directions |
| Why does `osql-result` emit one tuple at a time? | Generators calling `emit`, to avoid materializing result sets — footnote 14 |
| What is `cost "fiebfcost"` for? | DBA cost hints overriding defaults, "particularly useful for foreign predicates" |
| Why `_V1`, `_V2` in every plan? | Flattener-introduced intermediate variables, §3.1 |
| Why is the forward direction privileged? | Functions are normally used as methods computing properties of arguments, §3.4 |

And one divergence worth noting: the paper's default cost for an unannotated
foreign predicate is `(1 . 1)`; the tested build returns `(100 . 100)`.

## Related

- [`cost-based-vs-rule-based-optimization.md`](cost-based-vs-rule-based-optimization.md)
  — the cost model above compared with Polars' rule-based optimizer.
- [`query-rewrite/README.md`](query-rewrite/README.md) — TBR-rewrite rules, the
  later mechanism layered on top of the TBR representation described here.
- [`lisp-foreign-functions.md`](lisp-foreign-functions.md) — the modern ALisp
  form of the foreign-predicate interface of §5.
- [`amos-query-optimization-assignment/`](amos-query-optimization-assignment/)
  — an implementation of the exhaustive alternative to the ranking heuristic.
