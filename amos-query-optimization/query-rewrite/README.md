# TBR-rewrite rules — notes on `rewrite.txt`

[`rewrite.txt`](rewrite.txt) is official AMOS II documentation:
*"Accessing external data sources using TBR-rewrite rules."* It describes
the mechanism that lets the query optimizer transform ordinary data-access
predicates into **calls to specialised access routines** for external data
structures — the machinery behind, among other things, main-memory B-tree
(`mbtree`) index access.

> **Status of everything below.** This page summarises and interprets the
> document. Except where a transcript is shown, **none of it has been
> verified against a run** — treat it as claims to test, not facts. Per
> [`../CLAUDE.md`](../CLAUDE.md), documented behaviour and a given release's
> actual behaviour have already diverged in this repo. One such divergence
> is now settled by experiment in
> §"[Why `mbtree` ranges fail on this build](#why-mbtree-ranges-fail-on-this-build--resolved)":
> the rewrite rule described here is present and fires, but the foreign
> function it targets is missing from the tested build.

**Companion document:**
[`building-a-rewrite-rule.md`](building-a-rewrite-rule.md) is the hands-on
counterpart — a TBR-rewrite rule and its foreign access routine built from
nothing in Lisp, one verified step at a time, ending in the same
predicate-collapsing transformation §2 of `rewrite.txt` describes. Where
this page interprets the document, that one tests it.

## The problem it solves

AMOS II accesses external data through **wrappers**, each of which has two
parts:

| Part | Job |
|---|---|
| **Interface** | foreign functions that actually reach the source (connect, execute, return tuples as a bag of vectors) |
| **Translator** | converts AMOS II's internal S-expression predicate representation into calls to those interface functions |

The built-in JDBC/relational wrapper works on a **capabilities** model: a
source declares which functions it supports, and the translator must be able
to generate a complete query for *any conjunction* of calls to them.

That model breaks on a very common case — **a source that supports each
predicate individually but not every combination of them.** The document's
own example is exactly the one this repo cares about:

> a B-tree data structure supports conjunctions of the predicates `=`, `>`,
> `<`, `>=`, and `<=` but only implements certain combinations of these
> (interval queries).

Faced with an unsupported combination, the capabilities-based optimizer
simply **fails**. TBR-rewrite rules exist to fix this by letting a rule
**split a conjunction**: the part the structure can execute natively goes to
the access routine, and the remainder stays behind as a post-filter
evaluated by AMOS II.

## The worked example: `mbtree` range access

Given a stored function with B-tree indexes on both argument and result:

```sql
create function foo(integer x)->integer y key;
create_index("foo","x","mbtree",'unique');
create_index("foo","y","mbtree",'unique');
```

and the query:

```sql
select foo(i) from integer i where i>1 and i<=4 and i!=2;
```

The B-tree can only do **closed** intervals, so the open `i>1` is not
directly executable. The rewrite rule restates the query as:

```sql
select foo(i) from integer i where i>=1 and i<=4      -- B-tree can do this
                             and i!=1 and i!=2;        -- AMOS II post-filters
```

Note what happened: `i>1` became `i>=1` **plus** an extra `i!=1`. The
interval was widened to something the structure supports, and the
over-selection is corrected afterwards.

In the internal representation, this:

```lisp
(AND (#[OID 630 "P_INTEGER.FOO->INTEGER"] I _V1)   ; table FOO
     (#[OID 115 "OBJECT.OBJECT.>->BOOLEAN"] I 1)   ; >
     (#[OID 114 "OBJECT.OBJECT.<=->BOOLEAN"] I 4)  ; <=
     (#[OID 97 "OBJECT.OBJECT.!=->BOOLEAN"] I 2))  ; !=
```

becomes this:

```lisp
(AND (CALL MBT-SELECT-RANGE
        #[OID 407 "…MBT-SELECT-RANGE->BOOLEAN"]
        #[OID 630 "P_INTEGER.FOO->INTEGER"]  ; the table
        0                                    ; index position
        1                                    ; low bound
        4                                    ; high bound
        I _V1)                               ; returned argument + result
     (CALL OBJECT.!=-- #[OID 97 …] I 1)      ; post-filter
     (CALL OBJECT.!=-- #[OID 97 …] I 2))     ; post-filter
```

Three predicates collapsed into one indexed range scan plus two cheap
post-filters. The Lisp function performing this is `REWRITE-MBTINDEX`, and
the foreign function it targets is `MBT-SELECT-RANGE(f, pos, low, high)`,
which reads a closed interval `[low, high]` from the index at position `pos`
of stored function `f`. Open-ended intervals use a special marking.

## Why this matters for the `dynprogsort` assignment

**This is the headline.** §3 of the document states:

> The TBR-rewrite rule system is called by the cost-based optimizer. It is
> currently applied on conjunctions only **and only for the RANKSORT
> optimization.**

`ranksort` is AMOS II's *default* optimization method. The assignment
([`../amos-query-optimization-assignment/`](../amos-query-optimization-assignment/))
replaces it by setting `optmethod('exhaustive')`, which routes optimization
through the student-written `dynprogsort`.

That sentence is accurate, and it has now been **verified by a run** (see
[Test: switching the optimizer switches the failure](#test-switching-the-optimizer-switches-the-failure)
below). **Switching to exhaustive mode disables the TBR-rewrite rules**, and
with them `REWRITE-MBTINDEX` — so B-tree range access silently stops being
used under the very optimizer the assignment asks you to build. Worth
knowing before drawing conclusions from any `pc()` output taken under
`optmethod('exhaustive')`.

Two practical consequences follow, in opposite directions:

- **As a workaround:** `optmethod('exhaustive')` makes range queries on
  `mbtree`-indexed functions *work*, because it routes around the broken
  rewrite entirely and falls back to scan + post-filter.
- **As a trap:** any rewrite rule you write yourself will never fire under
  `optmethod('exhaustive')`. A custom rewriter can only be tested under
  `ranksort`.

### Where TR and TBR appear in `pc()` output

The names are visible in real transcripts recorded in
[`../amos-query-optimization-assignment/run-log.md`](../amos-query-optimization-assignment/run-log.md).
On the newer build, `objlog` prints stages including `Final TR`, `Absorbed`
and `TBR`; on the older build the corresponding stage is labelled
`Decomposed (TBR)`. So the pipeline runs roughly:

```
TR predicates  →  [ TBR-rewrite rules ]  →  TBR predicates  →  execution plan
(declarative)     (binding-pattern aware)   (access routines + CALLs)
```

`rewrite.txt` never expands the acronyms, but the paper it cites does, in
§2.3: **TR** = *Type Resolved*, **TBR** = *Type and Binding Pattern
Resolved*, with an earlier **TA** = *Type Adorned* stage before overload
resolution. See
[`../litwin-risch-1992-objectlog.md`](../litwin-risch-1992-objectlog.md).

**But note what the paper does *not* contain.** It describes cost-based rule
reordering, rule substitution, and the completion algorithm for inferring
unimplemented binding patterns — *not* the TBR-rewrite rule system this
document is about. There is no `REWRITE` struct, no `ADD-REWRITER`, no
user-registered rewriters in the 1992 design. The mechanism described in
`rewrite.txt` appears to be a later addition layered on top of the TBR
representation the paper defines. *(Absence from one paper is not proof of
later origin, but it is the only dating evidence available here.)*

That matters when reading the paper as a source: it is authoritative for the
**representation** — TR, TBR, binding patterns, cost and fanout — and silent
on the rewrite machinery.

### The connection to `substbindadorned`

§3 says that when no rewrite rule matches:

> `REWRITE-PRED` will translate THIS into the corresponding default
> TBR-predicate. The default TBR-predicate is identical to THIS for stored
> tables and for foreign functions a `CALL` statement is generated.

That is precisely the behaviour observed from `substbindadorned` in the
assignment work: stored-function predicates pass through unchanged, while
`>` becomes `(CALL GT-- #[OID 121 …] _V2 100000)`. So `substbindadorned`
appears to implement — or to sit directly on top of — the **default**
TR→TBR substitution, i.e. the path taken when no custom rewriter applies.

*(Unverified: whether `substbindadorned` consults the rewriter table at all,
or only ever performs the default substitution, is not established. Given
the RANKSORT-only restriction above, the latter seems likely under
`optmethod('exhaustive')`.)*

## Why `mbtree` ranges fail on this build — resolved

[`../CLAUDE.md`](../CLAUDE.md) records, as verified from a real run, that
`mbtree`:

> supports equality lookups like a multi-value hash index, but (on the AMOS
> II release tested) does **not** support `>`/`<` range predicates out of
> the box.

Yet this document's central example is `mbtree` handling exactly those range
predicates via `MBT-SELECT-RANGE`. A controlled experiment on the newer
build (`AmosNT_floq`, Release 16 v11) reconciles the two.

### The experiment

**With an `mbtree` index** — every range form fails identically:

    AmosQL 3> create function foo(integer x)->integer y key;
    #[OID 1753 "INTEGER.FOO->INTEGER"]
    AmosQL 4> create_index("foo","x","mbtree",'unique');
    {NIL,NIL}
    AmosQL 6> select foo(i) from integer i where i>1 and i<=4 and i!=2;
    No foreign implementation: NIL
    AmosQL 6> select foo(i) from integer i where i>=1 and i<=4 and i!=2;
    No foreign implementation: NIL
    AmosQL 6> select foo(i) from integer i where i>=1 and i<=4;
    No foreign implementation: NIL
    AmosQL 6> select foo(i) from integer i where i>=1;
    No foreign implementation: NIL

**Without any index** — the identical query succeeds:

    AmosQL 6> create function foo2(integer x)->integer y key;
    #[OID 1756 "INTEGER.FOO2->INTEGER"]
    AmosQL 7> select foo2(i) from integer i where i>=1 and i<=4 and i!=2;
    0.008 s

Same build, same session, same query text. The only variable is the presence
of the `mbtree` index. Neither function held any data, so this is a
**plan-time** failure, not a data-level one.

### Which indexes each function actually had

Inspecting them settles why the two behave differently. `indexes()` takes a
`Function` object, not a string — either `functionnamed("foo")` or the
shorthand `#"foo"` produces one:

    AmosQL 8> indexes(functionnamed("foo"));
    {#[OID 1754 "P_INTEGER.FOO->INTEGER"],0,"mbtree","unique"}
    {#[OID 1754 "P_INTEGER.FOO->INTEGER"],1,"hash","unique"}

The vector format is `{predicate-function, position, index-type,
uniqueness}`, where position 0 is the first argument and 1 the result.

Two things follow, and the first was not expected:

**`create_index` replaced the default index rather than adding to it.** The
manual states the system *"puts a unique index on the first argument of
stored functions"* by default — so `foo`'s `x` began with a hash index.
After `create_index("foo","x","mbtree",'unique')` position 0 shows
**`mbtree`**, not both. Running the same `create_index` twice also produced
no duplicate. So a position appears to hold exactly one index, and creating
another there replaces it. *(Inferred from the before/after reasoning, not
from a documented statement.)*

**`x` therefore had no hash fallback.** `foo`'s only access path on `x` was
the `mbtree`; the `hash` at position 1 indexes `y`, which the query never
constrains. `foo2`, by contrast, kept its default hash on `x`. That is the
whole difference:

| | index on `x` | range query on `x` |
|---|---|---|
| `foo` | `mbtree` only | rewritten to `MBT-SELECT-RANGE` → **missing** |
| `foo2` | default `hash` | no rewrite → scan + post-filter → **works** |

### What it proves

The rewrite rule **exists and fires**. Had `REWRITE-MBTINDEX` been absent or
failed to match, the query would have fallen back to a plain scan with
post-filters — slower, but working, exactly as `foo2` does. Instead the
optimizer rewrote the range into a call to `MBT-SELECT-RANGE` and then found
nothing bound to it.

So the missing piece is not the rule but its target, `MBT-SELECT-RANGE`.

Note also that a *single* open range (`i>=1`, no interval, no `!=`) is
enough to trigger the path. Any range predicate over an `mbtree`-indexed
function routes through the rewrite.

### The rewriter is registered by `create_index`, observed directly

The paragraph above argues the rule fires by elimination. `GET-REWRITERS`
shows it outright — and a control case shows what installs it:

    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo->integer) '(+ -))
    (REWRITE-MBTINDEX)
    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo->integer) '(- +))
    (REWRITE-MBTINDEX)
    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo2->integer) '(+ -))
    NIL

`foo` carries an `mbtree` index; `foo2` has only the default hash. The
rewriter is present on one and absent on the other, so
**`create_index(…,"mbtree",…)` is what registers the rule.** Index creation
and rewrite-rule registration are coupled — which is the real reason `foo`
and `foo2` diverge. It is not just a different index, it is a different
*translation path*.

Three further details:

**Rules attach to the predicate function, not the stored function.** The
lookup is on `P_INTEGER.FOO->INTEGER`, not `INTEGER.FOO->INTEGER`. §3 notes
in passing that "all stored functions are expressed in terms of the
corresponding predicate functions" when TBR rules run; this is that
statement made concrete.

**The binding pattern is the list form.** `'(+ -)`, the same adornment
representation `bindadornpat` produces in the assignment work — not the
`"bf"`/`"fb"` strings used in the AmosQL `multidirectional` syntax of §3.1's
`fie` example. The two notations coexist at different layers.

**One function serves both directions.** §2(ii) says "there are two
re-write rules … for the argument and the result," but what is registered is
a single `REWRITE-MBTINDEX` under both patterns, presumably branching on
`BPAT` internally.

### Test: switching the optimizer switches the failure

The step above reasons by elimination. This one is direct. §3 of
`rewrite.txt` restricts TBR rewrites to RANKSORT, so toggling the optimizer
should toggle the failure — and it does, in one session, same query text:

    AmosQL 11> optmethod('exhaustive');
    "exhaustive"
    0.018 s
    AmosQL 12> select foo(i) from integer i where i>=1;
    0.006 s
    AmosQL 13> optmethod('ranksort');
    "ranksort"
    0.025 s
    AmosQL 14> select foo(i) from integer i where i>=1;
    No foreign implementation: NIL
    0.004 s

(`foo` was unpopulated, so the successful run correctly returns no rows; the
point is that it *compiled and executed*.)

The document's own example query — the full conjunction, not just the single
open range — behaves the same way:

    AmosQL 18> optmethod('exhaustive');
    "exhaustive"
    0.018 s
    AmosQL 19> select foo(i) from integer i where i>1 and i<=4 and i!=2;
    0.014 s

That is the exact query from `rewrite.txt` §2 (line 87), the one the whole
B-tree rewrite example is built around. Under `ranksort` it is the first of
the four forms recorded as failing above. Under `exhaustive` it compiles.

Populating `foo` with the document's own data shows the fallback path is
also **semantically correct**, not merely compilable:

    AmosQL 20> set foo(1)=4; set foo(2)=3; set foo(3)=2; set foo(4)=0;
    NIL
    AmosQL 24> optmethod('exhaustive');
    "exhaustive"
    0.024 s
    AmosQL 25> select foo(i) from integer i where i>1 and i<=4 and i!=2;
    2
    0
    0.053 s

`i>1 and i<=4 and i!=2` selects `i` ∈ {3, 4}, giving `foo(3)=2` and
`foo(4)=0`. Correct.

And with the same data loaded, `ranksort` still fails:

    AmosQL 26> optmethod('ranksort');
    "ranksort"
    0.013 s
    AmosQL 27> select foo(i) from integer i where i>1 and i<=4 and i!=2;
    No foreign implementation: NIL
    0.006 s

So the failure is not an artifact of querying an empty function. It is
**plan-time**, it depends only on which optimizer is active, and it is fully
reversible in both directions within a single session.

### The fallback plan, seen directly

`pc()` needs a named function, so wrap the query in one. Note that it takes
**no argument** — `i` is bound entirely by the `FROM` clause, and declaring
a parameter `i` as well collides with it:

    AmosQL 29> create function f(number i) -> Bag of Number as
      select foo(i) from integer i where i>1 and i<=4 and i!=2;
    Error in function F:
    Duplicate declaration in F: (NUMBER I NONKEY) and (INTEGER I)

Declared without the parameter, under `exhaustive`:

    AmosQL 30> create function f() -> Bag of Integer as
      select foo(i) from integer i where i>1 and i<=4 and i!=2;
    #[OID 1765 "F->INTEGER"]
    AmosQL 31> pc("f");
    ----------------------------
    f()->Bag of Integer

    Execution plan:
    (F->INTEGER _V2+) <-
    (NESTED-LOOP-JOIN
       (MBTREE-FULL-SCAN #[OID 1753 "INTEGER.FOO->INTEGER"] I+ _V2+)
       (CALL #extpred "LE--"# #[OID 200 "OBJECT.OBJECT.<=->BOOLEAN"] I- 4)
       (CALL #extpred "NE--"# #[OID 196 "OBJECT.OBJECT.!=->BOOLEAN"] I- 2)
       (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] I- 1))

Three things in this plan are worth reading carefully.

**The `mbtree` index is scanned, not bypassed.** `MBTREE-FULL-SCAN` names
the index structure explicitly, and generates both `I+` and `_V2+` from it.
This is the strongest available confirmation that the index itself is
functional — the earlier sections established that only by elimination.
What the build lacks is a *range* entry point into a structure it can
otherwise read perfectly well.

**The post-filters take exactly the form §3 documents.** `rewrite.txt`
describes the default TR→TBR substitution for a foreign function as
producing `(CALL #extpred "NE--"# #[OID 97 …] I 2)`. The plan above produces
`(CALL #extpred "NE--"# #[OID 196 …] I- 2)` — same shape, session-local
OIDs. So this plan is the **default** translation path: what `REWRITE-PREDS`
does when no TBR rule applies, which under `exhaustive` is every predicate.

**`>1` survives as `>1`.** The plan filters with `GT-- I- 1` directly. There
is no widening to `>=1` and no compensating `!=1`. That transformation
exists only to fit a query to a B-tree's closed-interval limitation; a scan
evaluates `>` natively and needs no such correction.

### Side by side with the document's target plan

| | `rewrite.txt` §2 (RANKSORT + working B-tree) | This build (`exhaustive`) |
|---|---|---|
| Access path | `CALL MBT-SELECT-RANGE … 0 1 4 I _V1` | `MBTREE-FULL-SCAN … I+ _V2+` |
| Rows touched | only `[1,4]` | every row in `foo` |
| Post-filters | `!=1`, `!=2` | `<=4`, `!=2`, `>1` |
| `>1` handled by | widening to `>=1`, then `!=1` | evaluated directly |
| Correct result | yes | yes (`2`, `0`) |

Both compute the same answer. The difference is purely how much of the work
the index absorbs versus how much is left to post-filtering — which is the
entire point of §1's argument for the TBR-rewrite system.

*(One caveat on attribution: this plan was produced under
`optmethod('exhaustive')`. If `lab7.lsp` had been loaded into the session,
the ordering of the three post-filter `CALL`s would be the work of the
student-written `dynprogsort` rather than the built-in exhaustive optimizer.
Not established either way for this transcript.)*

Worth noting what the fallback path did *not* have to do. `rewrite.txt` §2
explains that the B-tree can only express **closed** intervals, so the
rewrite must widen `i>1` to `i>=1` and then add a compensating `i!=1`
post-filter to undo the widening. The scan path needs none of that — it
evaluates `>` directly. The entire widen-and-compensate dance exists to fit
the query to the index's limitations, which is precisely the kind of
capability mismatch §1 describes as the motivation for the TBR-rewrite
system.

This is conclusive: **the failure lives in the TBR-rewrite path, not in the
`mbtree` index.** The index structure is fine — the optimizer reaches it by
a different route under exhaustive and the query runs.

It also confirms §3's RANKSORT-only restriction behaviourally rather than on
the document's word, and incidentally shows that `optmethod` returns the
**new** setting, not the previous one.

### How much of `MBT-SELECT-RANGE` is actually missing

An earlier draft of this section concluded that `MBT-SELECT-RANGE` "has no
foreign implementation in this build … is not shipped here." **That was
wrong.** The object exists:

    Lisp 11> (getfunctionnamed 'mbt-select-range)
    #[OID 565 "MBT-SELECT-RANGE"]
    Lisp 11> (getfunctionnamed "MBT-SELECT-RANGE")
    No object found named MBT-SELECT-RANGE of type FUNCTION
    When evaluating: **LISPCALL**
    (FAULTEVAL BROKEN)
    Inside ERROR brk>

Two details narrow the diagnosis considerably.

**It prints bare, not typed.** `rewrite.txt` shows the target as
`#[OID 407 "FUNCTION.INTEGER.OBJECT.OBJECT.MBT-SELECT-RANGE->BOOLEAN"]` —
the fully-typed form, which in AMOS II denotes a **resolvent** (a specific
typed implementation). OID 565 prints as plain `MBT-SELECT-RANGE`, the form
a **generic function** takes. That is consistent with the generic being
present while no resolvent hangs under it — which is exactly what would
produce `No foreign implementation: NIL`, the `NIL` being the absent
implementation rather than an absent name.

**Symbol lookup finds it; string lookup does not.** The two calls take
different paths: the string form searches the AmosQL-visible name table and
misses, while the symbol form reaches an internal object. `rewrite.txt`
calls `MBT-SELECT-RANGE` *"an internal foreign AmosQL function"* — evidently
internal enough that ordinary AmosQL name resolution cannot see it.

So the corrected conclusion is narrower and more hopeful than the original:
**the declaration is present and the implementation binding is not.** This
is the same "declared but unbound" shape as the KDTREE case below, which
strengthens the missing-bootstrap-file lead rather than the
missing-capability one.

### Corroborated independently

The bare-vs-typed reading was inference when written. Building a foreign
function from scratch later in the same session reproduced the failure mode
exactly ([`building-a-rewrite-rule.md`](building-a-rewrite-rule.md) Step
5c). A rewrite rule was handed the **generic** function:

    (getfunctionnamed 'bar_range)   →  #[OID 1787 "BAR_RANGE"]

and the optimizer rejected the resulting predicate:

    (NOT-VALID-TBR:
       (BAR_RANGE 2 3 X _V2))

Passing the **resolvent** instead —
`#[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]`, found by looking
up the fully-typed name — produced a valid plan that ran.

So on this build: bare print form = generic = **no implementation attached**;
typed = resolvent = callable. That is precisely OID 565's situation, and it
is now demonstrated rather than inferred.

*(Still not directly inspected: the contents of OID 565 itself. `(objlog …)`
on it would show what the generic holds.)*

**Aside — escaping the break prompt.** The string-form error drops into
`Inside ERROR brk>`. **`:r` returns to the normal prompt** — verified later
in the same session against an `Inside NIL brk>` prompt raised by an
interrupt.

### Consequence for `CLAUDE.md`'s note

The observation there is correct; the mechanism is now known. It is not that
`mbtree` conceptually lacks range capability — the index structure is
ordered and the rewrite machinery to exploit it is present. The build simply
lacks the C-level function the rewrite calls. "Out of the box" turns out to
be carrying the whole weight of that sentence.

**Still untested:** whether equality lookups on the *same* indexed function
succeed (`select foo(i) from integer i where i=3;`, with `foo` populated).
That would complete the picture — native equality, absent-foreign-function
ranges — and is the one remaining gap in this reconstruction.

## Corroboration: the same mechanism, working, in the Mexima lab

A separate project —
`uu-db2-assign3-extensible-index` (UU DB2 assignment 3, extensible
indexing via **Mexima**, AMOS II's extensible index manager) — contains a
*working* instance of exactly the mechanism `rewrite.txt` describes, which
makes a useful control for the failure above.

### What it takes to add an index type

From that lab's notes, registering `KDTREE` required four distinct steps:

```sql
register_exindextype('KDTREE', FALSE);          -- 1. register the type
create function kdtree_make() -> Integer xid    -- 2. bind the generic ops
  as foreign 'JAVA:KDTreeIndex_Stub/kdtree_make';
-- …plus kdtree_put, kdtree_delete, kdtree_get, kdtree_clear
load_lisp('kdtree.lsp');                        -- 3. load the rewrite rule
create_index("features", "f", "KDTREE", "multiple");   -- 4. attach an instance
```

Mexima expects **five generic operations** from any index type: `make`,
`put`, `delete`, `get`, `clear`. Note what is *not* in that list — anything
resembling a range or proximity search. `kdtree_get` is an equality lookup.

So proximity search needed **two things beyond the generic interface**: a
separate foreign function `kdtreeProximitySearch`, and a separate Lisp
rewrite rule in `kdtree.lsp` teaching the optimizer that
`euclid(a,b) <= distance` may become a call to it. Once both were present,
the rewrite fired and the plan changed without the query's definition being
touched:

```lisp
(CALL #extpred "JAVA:KDTREEINDEX_STUB/KDTREEPROXIMITYSEARCH"#
   #[OID 4479 "…KDTREEPROXIMITYSEARCH->OBJECT"]
   12 _V2- DISTANCE- _V5+)      ; 12 = the KD-tree id create_index allocated
```

### Why this explains the `mbtree` failure

The structure maps one-to-one:

| | KDTREE (works) | MBTREE ranges (fails) |
|---|---|---|
| Registered index type | ✓ | ✓ — `mbtree` builds, and `MBTREE-FULL-SCAN` appears in plans |
| Generic five ops | ✓ → equality works | ✓ → equality / full scan work |
| Extra access routine | `kdtreeProximitySearch` ✓ | `MBT-SELECT-RANGE` ✗ **declared (OID 565) but unbound** |
| Rewrite rule | `kdtree.lsp` ✓ | `REWRITE-MBTINDEX` ✓ (it fires) |

**Range access was never part of the generic index interface.** It is a
bolt-on, structurally identical to proximity search — which is exactly why
`mbtree` can be a perfectly functional index (equality, full scans) while
ranges fail. The build has the rewrite rule and lacks only the binding for
the routine it calls.

### A lead: a missing *binding*, not a missing implementation

In the KDTREE case every foreign function had to be **explicitly declared**
before it existed to AmosQL:

```sql
create function kdtree_get(Integer kdId, Object o) -> Bag of Object
  as foreign 'JAVA:KDTreeIndex_Stub/kdtree_get';
```

`No foreign implementation: NIL` is precisely the symptom of a C routine
present in the binary but with no AmosQL declaration bound to it. The OID
565 finding above makes this the leading explanation: a **missing setup step
rather than a missing capability**. Worth searching the AMOS installation
for an unloaded bootstrap file:

```
grep -ril "mbt-select-range\|mbtindex" <amos install dir>
```

If an `mbtree.lsp` or equivalent `.osql` declaring `MBT-SELECT-RANGE` turns
up, `load_lisp(...)` on it may be all that is required. *(Untested.)*

### Two operational gotchas from that lab

1. **`recompile`, not `reoptimize`, picks up a new index.** The notes record
   that `pc()` showed the old plan after `create_index` *and* after
   `reoptimize`; only `recompile("closeWineSamples")` switched it. Relevant
   to any retest here, since the assignment work used `reoptimize`
   throughout.
2. **Loading a rewrite rule changes nothing on its own.** `create_index`
   must attach an instance of the index type to a specific column before any
   plan can change.

### And for a Lisp-only environment

The KDTREE *index* needed Java, but its **rewrite rule was plain Lisp**
(`kdtree.lsp`), and `rewrite.txt`'s `fie` example attaches Lisp functions as
foreign implementations directly. So the full TBR-rewrite mechanism —
foreign function, cost function, rewriter — can be demonstrated without any
C or Java toolchain.

**This has since been done.**
[`building-a-rewrite-rule.md`](building-a-rewrite-rule.md) builds a working
range-access rewrite entirely in Lisp on this build, collapsing
`bar(x) ∧ x>1 ∧ x<=3` into a single `CALL` — structurally the same
transformation §2 describes for `MBT-SELECT-RANGE`. `external.pdf` §3.2
turns out to make the Lisp route the *easiest* one: foreign functions
implemented in ALisp need neither a driver program nor function binding.

What still cannot be recovered this way is `MBT-SELECT-RANGE` itself, since
that is the shipped B-tree range routine — but nothing about the mechanism
around it is out of reach.

## Writing a rewrite rule

*Reference summary of what the document specifies. For a worked, verified
construction — every element below exercised against real runs — see
[`building-a-rewrite-rule.md`](building-a-rewrite-rule.md).*

A TBR-rewrite rule is a Lisp function named with a `REWRITE-` prefix, taking
one argument bound to a `REWRITE` struct:

```lisp
(DEFSTRUCT REWRITE
  THIS        ; the predicate currently being translated
  BPAT        ; its binding pattern
  BND         ; variables bound AFTER the call to THIS
  REST        ; the remaining TR predicates in the conjunction
  TRANSLATED) ; the TBR predicate THIS is translated into
```

`REST` is what makes the split possible: a rule may consume sibling
predicates out of the conjunction (the `i<=4` absorbed into the range) and
push replacements back (the added `i!=1`).

The function returns a control switch:

| Return | Meaning |
|---|---|
| `SUBSTITUTE` | perform the default TR→TBR substitution of `THIS` |
| `NIL` | this rule does not apply; skip it |
| `SUCCESS` | rule applied — `THIS` translated, `REST` possibly modified |

**Verified caveat on `NIL`:** "skip it" does *not* mean "fall back to the
default." With no other rule registered, returning `NIL` leaves `THIS`
untranslated and the query fails as not executable — shown in
[`building-a-rewrite-rule.md`](building-a-rewrite-rule.md) Step 1.
`SUBSTITUTE` is the correct return for a rule that declines to act.

### Supporting interface

| Function | Purpose |
|---|---|
| `(GET-TR-REWRITER FNO)` | get the TR rewriter for a function or its generic function |
| `(ADD-REWRITER FN BPAT REWRITER)` | declare a rewriter for `FN` under binding pattern `BPAT` |
| `(GET-REWRITERS FN BPAT)` | list rewriters for `FN` at `BPAT` |
| `(REWRITE-ASSERT PRED RW)` | add a predicate to the remaining conjunction |
| `(REWRITE-RETRACT PRED RW)` | remove a predicate from it |

Rules can also be attached per binding pattern when declaring a
multidirectional foreign function:

```sql
create function fie(integer x)->real y as multidirectional
        ("bf" foreign "fiebf" cost "fiebfcost" rewriter "fiebf")
        ("fb" foreign "fiefb" cost "fiefbcost" rewriter "fiefb");
```

Each direction gets its own implementation, **its own cost function**, and
its own rewriter — which is the same per-binding-pattern structure that
makes `(simple-pred-cost pred bpat)` in the assignment take `bpat` as an
argument.

### Preconditions

TBR rules run *after* the query rewrite system, so:

- all views are already expanded;
- stored functions appear as their *predicate functions* (the `P_…` OIDs
  seen throughout this repo's transcripts);
- **new TR expressions inserted into `REST` may not reference derived
  functions**, since the rules operate on view-expanded expressions.

## TBR-rewriters vs TR-rewriters

The document describes a second, simpler mechanism:

| | **TBR-rewriters** | **TR-rewriters** |
|---|---|---|
| Declared with | `ADD-REWRITER` / `rewriter` clause | `(DEFINE-TR-REWRITER FNO TESTFN ACTIONFN)` |
| Binding-pattern aware? | **yes** | no |
| Operates on | one predicate + the rest of the conjunction | a conjunction → an equivalent conjunction |
| Applied | once per predicate, per binding pattern tried | repeatedly **until a fix point** |
| Use when | the rewrite is low-level and depends on what is bound (B-trees) | the rewrite is a pure declarative equivalence |

The document's own guidance: *"If your rewrite rule depends on what is
bound, you need to use TBR rules."* It also warns that **TBR rules are
applied extensively**, because the optimizer tries many binding patterns —
so an expensive rewriter is evaluated far more often than one might expect.

## Why this is interesting beyond AMOS II

The capability-mismatch problem is not a historical curiosity. Any system
that pushes work into a source with partial query support meets it:
predicate pushdown into Parquet, filter pushdown to S3 Select, pushdown into
a REST API that supports some filters but not arbitrary boolean
combinations. The general answer is always the same shape as the one here —
**send down what the source can execute, keep the remainder as a local
post-filter** — and correctness requires the pushed-down part to be a
*superset* of what is wanted, exactly as `i>1` was widened to `i>=1` with
`i!=1` added behind it.

See
[`../cost-based-vs-rule-based-optimization.md`](../cost-based-vs-rule-based-optimization.md)
for how this relates to pushdown in modern engines.

## Source

`rewrite.txt` is part of the AMOS II documentation set
(<https://www.it.uu.se/research/group/udbl/amos/>). It references:

- the AMOS II User's Guide sections on `create_index` and cost functions;
- `external.pdf` on multidirectional foreign functions;
- `lispfunctions.txt` on predicate functions;
- W. Litwin and T. Risch (1992) for the TR predicate representation.
