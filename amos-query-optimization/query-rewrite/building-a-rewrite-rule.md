# Building a TBR-rewrite rule, step by step

A worked, runnable construction of a TBR-rewrite rule in AMOS II, built up
one verified step at a time. Companion to [`README.md`](README.md), which
analyses the official [`rewrite.txt`](rewrite.txt); this file is the
hands-on counterpart.

Every transcript below is real output from `AmosNT_floq` (Release 16 v11),
per [`../CLAUDE.md`](../CLAUDE.md)'s convention that no behaviour is written
down until a run has shown it.

**Where this ends up.** `rewrite.txt` §2's worked example rewrites

    select foo(i) from integer i where i>1 and i<=4 and i!=2;

into a single call to a B-tree range routine, `MBT-SELECT-RANGE`. On this
build that routine cannot run — see
[`README.md`](README.md#why-mbtree-ranges-fail-on-this-build--resolved).
Step 5 reconstructs the same design from scratch: three predicates
collapsed into one access call, with every piece written in Lisp.

**Constraint driving the design:** no C or Java toolchain is available. That
turns out to be no obstacle — `external.pdf` §3.2 states that foreign
functions implemented in ALisp need neither a driver program nor function
binding, and rewrite rules are Lisp by definition.

## Three things to know before starting

1. **Rules only fire under `ranksort`.** §3 restricts the TBR-rewrite system
   to that optimizer. Under `optmethod('exhaustive')` your rule is never
   called. Set it explicitly and keep the return value in the transcript —
   `pc()` never says which optimizer produced a plan.
2. **Rules attach to the *predicate* function.** Not `INTEGER.BAR->INTEGER`
   but `P_INTEGER.BAR->INTEGER`. §3 notes that by the time TBR rules run,
   "all stored functions are expressed in terms of the corresponding
   predicate functions." `indexes(functionnamed("bar"))` prints the
   predicate function's name and OID.
3. **Rules fire repeatedly.** §4 warns they "will be applied extensively
   since many different binding patterns will be tried by the optimizer."
   Seeing one rule print several times for a single query is normal.

## What TR and TBR mean

`rewrite.txt` never expands the acronyms, but both forms of the same
predicate are visible in the transcripts below. From Step 1, the `>`
predicate as it arrives in `REST`:

```lisp
(#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)                     ; TR
```

and the same predicate in the finished plan:

```lisp
(CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X- 1)   ; TBR
```

| | TR | TBR |
|---|---|---|
| Says | *what must be true* | *how to compute it* |
| Direction | none — multi-directional | one, fixed |
| Implementation | unspecified | named: `GT--` |
| Adornments | absent | present: `X-` = bound |

A TR predicate is declarative: `(> X 1)` does not say whether `X` arrives
bound or must be generated. A TBR predicate has chosen — it knows `X` is
bound, so it selects the implementation for that case and emits a `CALL`.

The `--` suffix in `GT--` **is** the binding pattern: both arguments bound,
hence a filter rather than a generator. This is what `substbindadorned`
produces in the `dynprogsort` exercise — that function is the TR→TBR step.

    TR predicates  →  [ TBR-rewrite rules ]  →  TBR predicates  →  plan
    (declarative)     (binding-pattern aware)   (CALLs + adornments)

A rewrite rule therefore sits at the moment of translation: after types are
known, at the instant a direction is chosen. That is why it receives `BPAT`,
and why `REST` arrives still in TR form — siblings are uncommitted, so they
can still be absorbed.

*(Inferred, not stated in the document: **TR** = type-resolved, **TBR** =
type- and binding-resolved, following the Litwin & Risch 1992 terminology
`rewrite.txt` cites. The behaviour above is what is actually verified.)*

## Step 0 — read the working example first

A functioning rewriter already exists in the image: `REWRITE-MBTINDEX`,
installed on `foo` by `create_index(…,"mbtree",…)`. Reading its registration
settles the API shape without guessing.

    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo->integer) '(+ -))
    (REWRITE-MBTINDEX)
    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo->integer) '(- +))
    (REWRITE-MBTINDEX)
    Lisp 41> (get-rewriters (getfunctionnamed 'p_integer.foo->integer) '(+ +))
    (REWRITE-MBTINDEX)
    Lisp 32> (get-rewriters (getfunctionnamed 'p_integer.foo2->integer) '(+ -))
    NIL

What this establishes:

- `GET-REWRITERS` takes a function object and a binding pattern.
- The pattern is the **list form** `'(+ -)` — the same adornment
  representation `bindadornpat` produces in the `dynprogsort` work, not the
  `"bf"`/`"fb"` strings of §3.1's AmosQL `multidirectional` syntax.
- `REWRITE-MBTINDEX` is registered on **all three** patterns, one Lisp
  function serving every direction, presumably branching on `BPAT`
  internally. §2(ii) describes this as "two re-write rules"; the
  implementation is one function registered three times.
- `foo2`, which has no `mbtree`, has **no rewriter** — so `create_index` is
  what installs the rule.

## Step 1 — a rule that only watches

Lisp debugging is unavailable on this build (`Error 44, Not supported`), so
`print` is the only way to see what the rewrite system hands a rule. Build
the observer before building anything that acts.

### Setup

    AmosQL 32> optmethod('ranksort');
    "ranksort"
    AmosQL 33> create function bar(integer x) -> integer y key;
    #[OID 1770 "INTEGER.BAR->INTEGER"]
    AmosQL 34> set bar(1)=10; set bar(2)=20; set bar(3)=30;
    AmosQL 37> indexes(functionnamed("bar"));
    {#[OID 1771 "P_INTEGER.BAR->INTEGER"],0,"hash","unique"}
    {#[OID 1771 "P_INTEGER.BAR->INTEGER"],1,"hash","unique"}

`bar` gets the default `hash` on both positions and no rewriter — a clean
baseline where the new rule is the only one in play.

### The rule

```lisp
(defun rewrite-spy (rw)
  (print (list 'this (rewrite-this rw)
               'bpat (rewrite-bpat rw)
               'bnd  (rewrite-bnd rw)
               'rest (rewrite-rest rw)))
  'substitute)
```

The `REWRITE-` prefix is required by §3.1. The four accessors come from
§3.1's `(DEFSTRUCT REWRITE THIS BPAT BND REST TRANSLATED)` — and unlike
`MAKE-PLANINFO` in the `dynprogsort` exercise, this struct **is** defined in
the image; the accessors work as-is.

### Registration

    Lisp 38> (add-rewriter (getfunctionnamed 'p_integer.bar->integer) '(+ -) 'rewrite-spy)
    #(TBR (+ -) NIL NIL NIL (REWRITE-SPY) NIL)
    Lisp 39> (add-rewriter (getfunctionnamed 'p_integer.bar->integer) '(+ +) 'rewrite-spy)
    #(TBR (+ +) NIL NIL NIL (REWRITE-SPY) NIL)
    Lisp 40> (add-rewriter (getfunctionnamed 'p_integer.bar->integer) '(- +) 'rewrite-spy)
    #(TBR (- +) NIL NIL NIL (REWRITE-SPY) NIL)
    Lisp 39> (get-rewriters (getfunctionnamed 'p_integer.bar->integer) '(+ -))
    (REWRITE-SPY)

Both the pattern and the rewriter name are **quoted**. Unquoted,
`rewrite-spy` would be read as a variable and fail with `Unbound variable`.

Registering on all three patterns avoids having to predict which one the
optimizer will try — the printed `BPAT` then reports it.

**Registration binds the symbol, not the definition.** `ADD-REWRITER` stores
the name `REWRITE-SPY` and looks the function up when it needs it. So these
three calls are the **only** registration in this entire document: every
later step redefines `rewrite-spy` with `defun` and the new body takes effect
immediately, on the same three patterns, with nothing to re-register.

That is worth knowing in both directions. It makes iteration fast — edit,
redefine, recompile the query, read the new plan. It also means a rule stays
installed after you stop thinking about it; `REWRITE-SPY` is still attached
to `bar` at the end of this document.

*Undocumented detail:* `ADD-REWRITER` returns an internal `#(TBR …)` struct
— six slots, of which slot 1 is the binding pattern and slot 5 the rewriter
list. Not mentioned in `rewrite.txt`. It shows rewriters are stored per
(function, binding-pattern) pair, which is why registration is three
separate calls rather than one.

### The first run failed — and the failure is instructive

The rule originally returned `NIL`, on the assumption that §3.1's "skip this
rule; it does not apply" meant the system would fall back to the default
translation. It does not:

    (THIS (#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2) BPAT (+ +) BND (_V2 X)
     REST ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))
    Error in function Q1:
    Query not executable.
        Detected when calling >
        Unbound variables: (X)

With `NIL` returned and no other rule registered, `bar`'s predicate was
never translated at all. `X` was therefore never produced, and the `>`
predicate was left with an unbound variable.

So the three control switches are genuinely three, not two:

| Return | Effect |
|---|---|
| `NIL` | rule declines; predicate stays untranslated unless another rule handles it |
| `SUBSTITUTE` | perform the default TR→TBR substitution of `THIS` |
| `SUCCESS` | the rule translated `THIS` itself, and may have changed `REST` |

**A rewriter is not a passive observer.** A rule that declines with nothing
behind it breaks the query. `SUBSTITUTE` is the correct return for an
observer.

### Working run

With `'substitute`:

    AmosQL 41> create function q1() -> Bag of Integer as
      select bar(x) from integer x where x>1;
    (THIS (#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2) BPAT (+ +) BND (_V2 X)
     REST ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))
    (THIS (#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2) BPAT (+ +) BND (_V2 X)
     REST ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))
    #[OID 1775 "Q1->INTEGER"]

    AmosQL 42> pc("q1");
    ----------------------------
    q1()->Bag of Integer

    Execution plan:
    (Q1->INTEGER _V2+) <-
    (NESTED-LOOP-JOIN
       (HASH-FULL-SCAN #[OID 1770 "INTEGER.BAR->INTEGER"] X+ _V2+)
       (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X- 1))

### Reading the dump

    THIS (#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2)
    BPAT (+ +)
    BND  (_V2 X)
    REST ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1))

- **`THIS`** is a predicate in exactly the S-expression form `rewrite.txt`
  §2 shows: a function OID applied to variables. `X` is the argument, `_V2`
  the result.
- **`BPAT (+ +)`** — both positions free, generated by scanning. This is the
  same pattern `REWRITE-MBTINDEX` is registered under for `foo`, and matches
  the `X+ _V2+` adornments in the plan.
- **`BND (_V2 X)`** — §3.1 defines BND as the variables bound *after* the
  call. The scan produces both.
- **`REST`** holds the `>` predicate still in **TR form**, not yet a `CALL`.
  This is the sibling a real rule reaches in and absorbs.

The rule fired **twice** for one query, consistent with §4's warning.

### What the plan confirms

`SUBSTITUTE` produced precisely the default translation §3 describes:
stored-function predicates pass through as a scan, and the foreign `>`
becomes `(CALL #extpred "GT--"# …)` — the same `#extpred` form
`rewrite.txt` uses in its own example.

## Step 2 — a rule that changes the plan

§3.1 gives two functions for editing the remaining predicates:

    (REWRITE-ASSERT PRED RW)    Assert new fact among remaining predicates
    (REWRITE-RETRACT PRED RW)   Retract fact from remaining predicates

Both take the predicate **first** and the context struct second, and both
work by **mutating `RW`** rather than returning a new value — which is why
they need the whole struct and not just the `REST` list.

The smallest possible change: delete a sibling and watch it vanish from the
plan.

```lisp
(defun rewrite-spy (rw)
  (print (list 'before (rewrite-rest rw)))
  (let ((p (car (rewrite-rest rw))))
    (cond (p (rewrite-retract p rw))))
  (print (list 'after (rewrite-rest rw)))
  'substitute)
```

Printing `REST` on both sides of the call separates two questions that would
otherwise fail identically: *did the retract take effect*, and *did the plan
honour it*.

This rule is deliberately crude — it swallows whatever is first in `REST`
without checking what it is. For a query whose `REST` holds exactly one
predicate that is safe, and it keeps the mechanism visible without
pattern-matching code in the way.

### Result

    AmosQL 44> create function q2() -> Bag of Integer as
      select bar(x) from integer x where x>1;
    Redefining #[OID 1777 "Q2->INTEGER"]
    Recompiling #[OID 1777 "Q2->INTEGER"]
    (BEFORE ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))
    (AFTER NIL)
    (BEFORE NIL)
    (AFTER NIL)
    #[OID 1777 "Q2->INTEGER"]

    AmosQL 45> pc("q2");
    ----------------------------
    q2()->Bag of Integer

    Execution plan:
    (Q2->INTEGER _V2+) <-
    (HASH-FULL-SCAN #[OID 1770 "INTEGER.BAR->INTEGER"] X+ _V2+)

    AmosQL 45> q2();
    10
    20
    30

### What this establishes

**`REWRITE-RETRACT` mutates the struct.** `BEFORE` holds the `>` predicate,
`AFTER` is `NIL`.

**`REST` edits survive a `SUBSTITUTE` return.** This was genuinely
uncertain: §3 mentions changing `REST` only in its description of `SUCCESS`,
which suggested edits might be discarded on the default path. They are not.
A rule may therefore change `REST` while leaving `THIS` to the default
translation — useful, because it means absorbing siblings does not oblige
you to construct `TRANSLATED` yourself.

**The mutation persists across firings.** The rule fires twice, and the
second firing's `BEFORE` is already `NIL` — the same struct carries over
rather than being rebuilt per attempt. A real rule must therefore tolerate
being called again after it has already consumed its siblings.

**The plan changed structurally, not just cosmetically.** Compare `q1`:

```lisp
(NESTED-LOOP-JOIN                          ; q1
   (HASH-FULL-SCAN … X+ _V2+)
   (CALL #extpred "GT--"# … X- 1))

(HASH-FULL-SCAN … X+ _V2+)                 ; q2
```

With only one operator left there is nothing to join, so the
`NESTED-LOOP-JOIN` disappeared too.

**And the answer is now wrong — deliberately.** `q2()` returns `10 20 30`
instead of `20 30`, because the `x>1` condition was deleted and nothing
replaced it. That wrong answer is the proof: the rule reached into the
optimizer and changed what executes. On three rows of known data it is
obvious at a glance; the same error inside a real rule would be silent.

### Incidental: how to force a re-plan

Redefining an existing function is enough:

    Redefining #[OID 1777 "Q2->INTEGER"]
    Recompiling #[OID 1777 "Q2->INTEGER"]

The recompile re-runs the rewriters, so a new function name is not needed to
test a changed rule.

## Step 3a — `REWRITE-ASSERT`, in isolation

Before asking `assert` to do anything clever, check it round-trips: retract
a predicate and put the *same one* straight back.

```lisp
(defun rewrite-spy (rw)
  (let ((p (car (rewrite-rest rw))))
    (cond (p (rewrite-retract p rw)
             (rewrite-assert p rw)
             (print (list 'roundtrip (rewrite-rest rw))))))
  'substitute)
```

    (ROUNDTRIP ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))
    (ROUNDTRIP ((#[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X 1)))

    Execution plan:
    (Q2->INTEGER _V2+) <-
    (NESTED-LOOP-JOIN
       (HASH-FULL-SCAN #[OID 1770 "INTEGER.BAR->INTEGER"] X+ _V2+)
       (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] X- 1))

    AmosQL 46> q2();
    20
    30

Plan restored to its original shape, correct answer back. So
`REWRITE-ASSERT` accepts a predicate in exactly the S-expression form `REST`
hands you, and retract-then-assert is a safe round trip.

## Step 3b — a real transformation, and the bug it exposes

Now transform rather than restore: absorb `x>1` and emit `x>=2`. On integers
those are equivalent, so the answer should stay correct while the plan
changes.

    Lisp 47> (getfunctionnamed 'object.object.>=->boolean)
    #[OID 204 "OBJECT.OBJECT.>=->BOOLEAN"]

```lisp
(defun rewrite-spy (rw)
  (let ((p (car (rewrite-rest rw)))
        (ge (getfunctionnamed 'object.object.>=->boolean)))
    (cond (p
           (let ((v (car (cdr p)))              ; the variable, X
                 (k (car (cdr (cdr p)))))       ; the constant, 1
             (rewrite-retract p rw)
             (rewrite-assert (list ge v (+ k 1)) rw)
             (print (list 'rewrote p 'into (rewrite-rest rw)))))))
  'substitute)
```

A TR predicate arrives as `(OID X 1)`, so it comes apart with `car`/`cdr`:

| Expression | Value |
|---|---|
| `(car p)` | the `>` function object |
| `(car (cdr p))` | `X` |
| `(car (cdr (cdr p)))` | `1` |

and `(list ge v (+ k 1))` builds a fresh one in the same shape.

### It ran away

    (REWROTE (#[OID 202 "…>->BOOLEAN"] X 1) INTO ((#[OID 204 "…>=->BOOLEAN"] X 2)))
    (REWROTE (#[OID 204 "…>=->BOOLEAN"] X 2) INTO ((#[OID 204 "…>=->BOOLEAN"] X 3)))

    (CALL #extpred "GE--"# #[OID 204 "OBJECT.OBJECT.>=->BOOLEAN"] X- 3)

`x>1` became `x>=2` became `x>=3`. The rule fires twice, and on the second
firing the predicate sitting first in `REST` was **its own output**, which
it dutifully incremented again.

The missing property is **idempotence** — applying the rule twice should
equal applying it once. Since the optimizer calls rules repeatedly (§4:
"applied extensively"; TR-rewriters are explicitly run "until a fix point is
reached"), a non-idempotent rule drifts further from correct on every call.

Note the failure is **silent**: no error, a perfectly plausible plan, and a
wrong answer. Visible here only because the data is three known rows.

## Step 3c — guard the rule

A rewrite rule sees *every* matching predicate in *every* query, not just
the one it was written for. It must verify the shape it knows how to
transform and decline otherwise.

```lisp
(defun rewrite-spy (rw)
  (let ((p  (car (rewrite-rest rw)))
        (gt (getfunctionnamed 'object.object.>->boolean))
        (ge (getfunctionnamed 'object.object.>=->boolean)))
    (cond ((and p
                (eq (car p) gt)                        ; is it really ">"?
                (numberp (car (cdr (cdr p)))))         ; is the bound a number?
           (let ((v (car (cdr p)))
                 (k (car (cdr (cdr p)))))
             (rewrite-retract p rw)
             (rewrite-assert (list ge v (+ k 1)) rw)
             (print (list 'rewrote p 'into (rewrite-rest rw)))))))
  'substitute)
```

- **`(eq (car p) gt)`** — `(car p)` is the predicate's function object.
  On the second firing it is `>=`, not `>`, so the guard rejects it and the
  runaway stops.
- **`(numberp …)`** — `(+ k 1)` needs a number. A query like `where x > y`
  would otherwise crash deep inside compilation.
- `and` short-circuits, so `p` being `NIL` is handled before anything
  touches it.

### Result

    (REWROTE (#[OID 202 "…>->BOOLEAN"] X 1) INTO ((#[OID 204 "…>=->BOOLEAN"] X 2)))

    Execution plan:
    (Q2->INTEGER _V2+) <-
    (NESTED-LOOP-JOIN
       (HASH-FULL-SCAN #[OID 1770 "INTEGER.BAR->INTEGER"] X+ _V2+)
       (CALL #extpred "GE--"# #[OID 204 "OBJECT.OBJECT.>=->BOOLEAN"] X- 2))

    AmosQL 49> q2();
    20
    30

One `REWROTE` print instead of two — the second firing declined silently.
`GE--` with bound 2, and the correct answer.

**This is a complete rewrite rule:** it changes the plan, preserves
semantics, and is stable under repeated application.

### Contrast with the B-tree rule

`rewrite.txt` §2 performs the *opposite* conversion — `i>1` becomes `i>=1`
**plus** a compensating `i!=1`:

    select foo(i) from integer i where i>=1 and i<=4 and i!=1 and i!=2;

Widening to `>=1` admits a row the original excluded, so the B-tree gets a
loose closed interval and a post-filter cleans up afterwards. Lossy,
requiring compensation.

The rule above is exact: on integers `>1` and `>=2` select identically, so
nothing needs cleaning up. That shortcut is available only because the type
is known to be integer — knowledge a generic B-tree rule cannot assume.

## Step 4 — the gate: can a foreign function be written in Lisp?

Everything so far rewrites predicates into *other predicates*. Translating
`THIS` into a `CALL` to a purpose-built access routine — the
`MBT-SELECT-RANGE` pattern — needs something to call. With no C or Java
toolchain, that has to be Lisp.

**It works**, and it turns out to be the least troublesome of the three
foreign-function interfaces: `external.pdf` §3.2 states that an ALisp
implementation needs neither a driver program nor function binding, unlike C
and Java.

> **The protocol, declaration syntax, `osql-result` rules, the `osql`
> callin interface and the gotchas are documented separately in
> [`../lisp-foreign-functions.md`](../lisp-foreign-functions.md).** This
> section covers only what the rewrite work needed to establish.

### What this step had to prove

Two things, before a rule could safely depend on them.

**That a Lisp foreign function runs at all.**

```lisp
(defun sqrtbf (fno x r)          ; x known, r computed
  (cond ((= x 0) (osql-result x 0.0))
        ((> x 0) (setq r (sqrt x))
                 (osql-result x r)
                 (osql-result x (- 0 r)))))

(defun sqrtfb (obj x r)          ; r known, x computed
  (osql-result (* r r) r))
```

    AmosQL 51> create function mysqrt(real x) -> real as multidirectional
      ('bf' foreign 'sqrtbf')('fb' foreign 'sqrtfb');
    #[OID 1780 "REAL.MYSQRT->REAL"]
    AmosQL 52> mysqrt(4.0);
    2.0
    -2.0

Two tuples from one call — so the stream protocol works, which a range
routine depends on entirely.

**That AMOS II dispatches on binding pattern.**

    AmosQL 52> select x from number x where mysqrt(x)=4.0;
    WARNING: Coercing argument in call to mysqrt(Real)->Real
    16.0

`16.0` is `(* r r)` from `sqrtfb`. Binding the result instead of the
argument selected a *different Lisp function*.

This is the premise the entire TBR-rewrite system rests on — the same
predicate resolving to different code depending on what is bound, which is
why rules receive `BPAT` and why §4 says "if your rewrite rule depends on
what is bound, you need to use TBR rules." Worth one extra function to
verify rather than assume.

### Why multi-directional, when Step 5 does not use it

`bar_range` in Step 5 is declared single-direction, and the rule fires only
on `(+ +)`. The multi-directional test exists to confirm the premise above,
not because the finished rule needs it.

A production index would need every direction:

| Situation | Pattern | Access path |
|---|---|---|
| `bar(2)` — key known | `(- +)` | index lookup |
| `bar(x)=20` — value known | `(+ -)` | lookup via the index on `y` |
| `bar(x) ∧ x>1 ∧ x<=3` | `(+ +)` | range scan ← Step 5's case |

Which is exactly why `REWRITE-MBTINDEX` is registered on all three, and why
§2(ii) describes splitting the predicate "differently depending on whether
the argument or the result is bound."

Note also that the `'bf'`/`'fb'` strings in the AmosQL declaration and the
`'(+ -)` lists passed to `ADD-REWRITER` are the same concept at different
layers. `rewrite.txt` §3.1 joins them in one statement:

```sql
create function fie(integer x)->real y as multidirectional
        ("bf" foreign "fiebf" cost "fiebfcost" rewriter "fiebf")
        ("fb" foreign "fiefb" cost "fiefbcost" rewriter "fiefb");
```

That is the declarative alternative to calling `ADD-REWRITER` by hand, and
the shape a finished Step 5 could adopt.

### Two traps hit along the way

**A built-in name silently shadowed the code.** The function was first named
`sqrt`, which AMOS II already defines. `create` registered an *overload*,
`#[OID 1778 "REAL.SQRT->REAL"]`, and calls resolved to the built-in —
returning a single `2.0` and ignoring every redefinition of the Lisp
function. It looked like caching. The Lisp code had simply never run.
Renaming to `mysqrt` fixed it at once.

**`select … for each …` is a parse error.** AmosQL's select clause is
`from`:

    select x from number x where mysqrt(x)=4.0;


## Step 5a — the shape of a `CALL`

A rewriter that returns `SUCCESS` must build `TRANSLATED` itself. Rather
than deduce the format, get AMOS II to emit one for a Lisp foreign function
and copy it:

    AmosQL 59> create function q3() -> Bag of Real as select mysqrt(4.0);
    AmosQL 60> pc("q3");
    (Q3->REAL _V2+) <-
    (CALL SQRTBF #[OID 1780 "REAL.MYSQRT->REAL"] 4.0 _V2+)

    AmosQL 61> create function q4(Real r) -> Bag of Real as
      select x from real x where mysqrt(x) = r;
    AmosQL 62> pc("q4");
    (REAL.Q4->REAL R- X+) <-
    (CALL SQRTFB #[OID 1780 "REAL.MYSQRT->REAL"] X+ R-)

So the form is:

```lisp
(CALL <lisp-implementation-symbol>
      <amosql-function-object>
      <arg1> ... <argN> <res1> ... <resM>)
```

Four things this establishes:

**A Lisp foreign function appears as a bare symbol.** `SQRTBF`, not
`#extpred "SQRTBF"#`. The `#extpred …#` wrapper seen on `GT--`, `LE--`,
`NE--` marks a **C**-implemented predicate. This matches `rewrite.txt` §2,
where `MBT-SELECT-RANGE` — described there as a Lisp function — also appears
bare.

**Positions follow the declaration, not the direction.** `sqrtfb` computes
`x` from `r`, yet its call still lists `X` before `R`. Only the adornments
flip. The same rule governs `osql-result`: tuple order is fixed by the
signature.

**Adornments carry the direction.** `X+` is produced, `R-` is consumed.

**Constants appear bare.** `4.0` has no adornment — nothing to bind.

## Step 5b — the access routine

`MBT-SELECT-RANGE` returns every row of an index within a closed interval.
This is the Lisp equivalent for `bar`.

### Reading AmosQL data from Lisp

The routine needs `bar`'s contents. `external.pdf` §2.2's embedded-query
interface provides them — see
[`../lisp-foreign-functions.md`](../lisp-foreign-functions.md#calling-amosql-from-lisp)
for the mechanism. Tested standalone first, outside any foreign function, so
that a failure later could not be ambiguous between the two:

```lisp
(defun try-bar (i)
  (osql-let ((integer :i) (integer :v))
    (setq AMOS_i i)
    (osql "select bar(:i) into :v;")
    (print AMOS_v)))
```

    Lisp 62> (try-bar 2)
    20
    Lisp 62> (try-bar 99)
    NIL

A **miss leaves the variable `NIL`** rather than erroring — so `(cond
(AMOS_v …))` is a valid guard for gaps in the key range.

### The range function

```lisp
(defun bar-range-fn (fno lo hi x y)
  (osql-let ((integer :i) (integer :v))
    (setq AMOS_i lo)
    (while (<= AMOS_i hi)
      (setq AMOS_v nil)
      (osql "select bar(:i) into :v;")
      (cond (AMOS_v (osql-result lo hi AMOS_i AMOS_v)))
      (setq AMOS_i (+ AMOS_i 1)))))
```

    AmosQL 62> create function bar_range(Integer lo, Integer hi)
                 -> Bag of <Integer x, Integer y> as foreign 'bar-range-fn';
    #[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]
    AmosQL 63> bar_range(1,3);
    (1,10)
    (2,20)
    (3,30)

Points worth noting:

- **`osql-result` takes four arguments** — `lo hi x y`. Arity 2 + width 2.
  Only the result half `<x,y>` is displayed; the arguments are echoed back
  as part of the tuple but not printed as output columns.
- **`AMOS_v` is reset each iteration.** Inside a loop the variable persists
  between passes, so without the reset a missing key would re-emit the
  previous row.
- **`Bag of <Integer x, Integer y>` is accepted** as a result type, though
  `external.pdf` §3.2 writes tuple results without the `Bag of` prefix.
- **Calling `osql` from inside a foreign function works.** This was the
  design's main risk — it re-enters the query system while a query is
  executing. `external.pdf` §1 sanctions it ("the system furthermore allows
  the callin interface to be used in the foreign functions, which gives
  great flexibility"), and it does work in practice.

A linear scan over the integer range is obviously not what a B-tree does.
Efficiency is not the point — the translation is. A real implementation
would hold its own ordered structure, as the KDTREE lab does and as
`MBT-SELECT-RANGE` does by reading the B-tree directly.

## Step 5c — the rewriter, and the finished result

The rule replaces `THIS` instead of merely editing `REST`, which means
writing `TRANSLATED` and returning `SUCCESS`.

### `setf` works

Every earlier step only *read* struct fields. Writing one was unverified:

    Lisp 63> (defstruct tst a b)
    Lisp 63> (setq z (make-tst :a 1))
    #(TST 1 NIL)
    Lisp 63> (setf (tst-a z) 99)
    99
    Lisp 63> (tst-a z)
    99

### The rule

```lisp
(defun rewrite-spy (rw)
  (let ((this (rewrite-this rw))
        (gt (getfunctionnamed 'object.object.>->boolean))
        (ge (getfunctionnamed 'object.object.>=->boolean))
        (lt (getfunctionnamed 'object.object.<->boolean))
        (le (getfunctionnamed 'object.object.<=->boolean))
        (br (getfunctionnamed 'integer.integer.bar_range->integer.integer))
        (xv nil) (yv nil) (lo nil) (hi nil) (lop nil) (hip nil))
    (setq xv (car (cdr this)))
    (setq yv (car (cdr (cdr this))))
    (dolist (p (rewrite-rest rw))
      (cond ((and (eq (car (cdr p)) xv)
                  (numberp (car (cdr (cdr p)))))
             (let ((op (car p))
                   (k (car (cdr (cdr p)))))
               (cond ((eq op gt) (setq lo (+ k 1)) (setq lop p))
                     ((eq op ge) (setq lo k)       (setq lop p))
                     ((eq op lt) (setq hi (- k 1)) (setq hip p))
                     ((eq op le) (setq hi k)       (setq hip p)))))))
    (cond ((and lo hi (equal (rewrite-bpat rw) '(+ +)))
           (rewrite-retract lop rw)
           (rewrite-retract hip rw)
           (setf (rewrite-translated rw)
                 (list 'CALL 'BAR-RANGE-FN br lo hi xv yv))
           (print (list 'translated (rewrite-translated rw)))
           'success)
          (t 'substitute))))
```

### Walked through with `q5`

Take the query the rule was built for:

```sql
create function q5() -> Bag of Integer as
  select bar(x) from integer x where x>1 and x<=3;
```

Its conjunction is `bar(x)=_V2 ∧ x>1 ∧ x<=3`. When the optimizer reaches the
`bar` predicate it hands the rule a `REWRITE` struct holding:

| Field | Value |
|---|---|
| `THIS` | `(#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2)` |
| `BPAT` | `(+ +)` |
| `BND` | `(_V2 X)` |
| `REST` | `((#[OID 202 "…>->BOOLEAN"] X 1) (#[OID 200 "…<=->BOOLEAN"] X 3))` |
| `TRANSLATED` | — empty on entry |

The first four are **inputs**: the struct arrives carrying them and the rule
reads them. `TRANSLATED` is the **output** — §3.1's "the TBR predicate THIS is
translated into". It is the field the rule fills in when it wants to replace
`THIS` itself, and the only one written here.

Note what is **not** there: `q5` is never mentioned. Nothing ever binds a
rewriter to a query. The only command that connected this rule to anything
was run back in [Step 1](#registration), long before `q5` existed:

```lisp
(add-rewriter (getfunctionnamed 'p_integer.bar->integer) '(+ +) 'rewrite-spy)
```

That names a **function** — `bar`'s predicate function — and a **binding
pattern**. `q5` reaches the rule only by *containing* a `bar` call, which
becomes the TR predicate `(#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2)`; when
the optimizer goes to translate it, it looks up the rewriters registered for
that function at that pattern and finds `REWRITE-SPY`.

The same rule fired on `q1` and `q2` for the same reason, and would fire on
any future query mentioning `bar`. That is why Step 3c's guards matter: a
rule is offered every matching predicate in every query, indefinitely.

#### The variables

| Variable | Holds | Value for `q5` |
|---|---|---|
| `rw` | the whole `REWRITE` struct — the rule's only parameter | — |
| `this` | `THIS`, the predicate being translated | `(#[OID 1771 "P_INTEGER.BAR->INTEGER"] X _V2)` |
| `gt` `ge` `lt` `le` | function objects for `>` `>=` `<` `<=`, looked up once so the loop can compare against them | `>` is OID 202, `>=` 204, `<=` 200 |
| `br` | the **resolvent** of `bar_range` — what the emitted `CALL` must name | `#[OID 1788 …BAR_RANGE…]` |
| `xv` | `bar`'s **argument** variable | `X` |
| `yv` | `bar`'s **result** variable | `_V2` |
| `lo` / `hi` | the computed closed bounds; `nil` until found | `2` / `3` |
| `lop` / `hip` | the *predicates* those bounds came from | the `>` and `<=` predicates |

The `lo`/`lop` pairing is the part worth pausing on. Two different things are
needed from one sibling: the **number** to put in the call, and the
**predicate object** to hand to `rewrite-retract`. `lo` is `2`; `lop` is the
whole `(#[OID 202 "…>->BOOLEAN"] X 1)` expression. Retracting `2` would mean
nothing.

`yv` is never searched for in `REST` — it is read straight out of `THIS` and
passed through to the call, because `bar_range` returns it.

#### Step by step

**1. Take the predicate apart.** A TR predicate is a flat list, so `car`/`cdr`
peel positions off it:

```lisp
(setq xv (car (cdr this)))          ; X
(setq yv (car (cdr (cdr this))))    ; _V2
```

**2. Walk `REST`.** For each sibling `p`, two guards decide whether it is
usable:

```lisp
(eq (car (cdr p)) xv)               ; does it constrain X, not some other variable?
(numberp (car (cdr (cdr p))))       ; is the bound a literal number?
```

The first matters more than it looks. A conjunction may contain conditions on
entirely unrelated variables, and folding one of those into a range over `x`
would silently change the query's meaning.

**3. Classify and normalise.** `(car p)` is the sibling's function object, so
comparing it against `gt`/`ge`/`lt`/`le` identifies the operator, and each
branch converts to a **closed** bound:

| Sibling | Branch | Sets |
|---|---|---|
| `x>1` | `(eq op gt)` | `lo = 1+1 = 2`, `lop` = that predicate |
| `x<=3` | `(eq op le)` | `hi = 3`, `hip` = that predicate |

`ge` and `lt` never fire for `q5`; they are there for `x>=1` and `x<3` forms.
The `dolist` handles both siblings regardless of order, which is why it walks
the list rather than indexing into it the way Steps 2 and 3 did — nothing
promises `>` comes before `<=`.

**4. Decide whether to act.**

```lisp
(and lo hi (equal (rewrite-bpat rw) '(+ +)))
```

Both bounds must be present — a half-open range is not something `bar_range`
can serve — and the binding pattern must be `(+ +)`, the scan case where a
range helps. Anything else falls through to `'substitute` and the query
compiles normally.

**5. Absorb and replace.**

```lisp
(rewrite-retract lop rw)            ; REST loses  x>1
(rewrite-retract hip rw)            ; REST loses  x<=3
(setf (rewrite-translated rw)
      (list 'CALL 'BAR-RANGE-FN br lo hi xv yv))
'success
```

Which builds exactly what the transcript below shows:

```lisp
(CALL BAR-RANGE-FN #[OID 1788 …BAR_RANGE…] 2 3 X _V2)
        │              │                   │ │  │  │
        │              │                   │ │  └──┴─ results: bar's x and y
        │              │                   └─┴─────── arguments: lo, hi
        │              └───────────────────────────── the resolvent
        └──────────────────────────────────────────── the Lisp implementation
```

Four value positions — `2 3 X _V2` — matching `bar_range(lo,hi) -> <x,y>`:
arity 2 plus width 2, the same counting rule `osql-result` obeys. They are
preceded by the implementation name and the function object.

*Why both of those?* A single resolvent can carry several implementations —
Step 5a's two plans show `SQRTBF` and `SQRTFB` under the **same** OID 1780 —
so the function object alone cannot say which code to run. The object
identifies *which AmosQL function*, the symbol *which implementation of it*.
That object is also what arrives as `fno`, the first parameter of the Lisp
function being called.

*Why retract at all?* Leaving `x>1` and `x<=3` in `REST` would not be wrong —
`bar_range(2,3)` returns only tuples those filters accept, so the answer is
unchanged. It would just re-test every returned tuple against conditions the
call already guarantees, leaving a join and two post-filters in a plan that
should have one operator: an index access path added and none of the old work
removed. Retraction is a **transfer of responsibility** — retract exactly what
the new call enforces. Retract more and the answer is silently wrong, which is
what [Step 2](#step-2--a-rule-that-changes-the-plan) demonstrated; retract less
and the rewrite buys nothing. `rewrite.txt` §2 splits the difference: its
widened `MBT-SELECT-RANGE(1,4)` enforces *less* than `i>1`, so the rule asserts
a compensating `i!=1` to cover the gap.

#### The three quoted symbols, and `t`

```lisp
           (print (list 'translated (rewrite-translated rw)))
           'success)
          (t 'substitute))))
```

Three quoted symbols doing three different jobs.

**`'translated` is a label.** Quoting it means "the symbol, literally" — do
not look for a variable by that name. It is there purely so the printed line
reads `(TRANSLATED (CALL …))` instead of an unlabelled blob, the same trick
Step 1's spy used with `'this`, `'bpat`, `'bnd` and `'rest`. It has no
connection to the `TRANSLATED` struct field beyond being spelled the same;
the field is read by `(rewrite-translated rw)` right next to it.

**`'success` and `'substitute` are the return value.** A Lisp function
returns its last expression, and here that last expression is whichever
`cond` branch ran — so the rule returns one of the two control switches from
§3.1:

| Branch | Returns | Means |
|---|---|---|
| guard passed | `'success` | *I translated `THIS` myself — use my `TRANSLATED`* |
| guard failed | `'substitute` | *translate `THIS` the default way* |

Both are quoted for the same reason as `'translated`: unquoted, `success`
would be read as a variable and fail with `Unbound variable: SUCCESS`.

**`t` is the catch-all.** `cond` tries each clause's test in order and runs
the first that is true. `t` is Lisp's true constant, so a clause beginning
with `t` always matches — it is the `else` at the end of the chain:

```lisp
(cond ((and lo hi …)  … 'success)     ; when the guard passes
      (t              'substitute))   ; otherwise
```

Without it, a failing guard would leave `cond` with no matching clause,
`cond` would return `NIL`, and `NIL` is the third control switch — the one
[Step 1](#the-first-run-failed--and-the-failure-is-instructive) showed breaks
the query. The `t` clause is what keeps a declined rewrite harmless.

#### Why the second firing does nothing

The rule fires twice, but the transcript shows only one `TRANSLATED` print.
Nothing guards against re-entry explicitly — the retraction does it. By the
second firing `REST` no longer holds the two bounds, so `lo` and `hi` stay
`nil`, `(and lo hi …)` fails, and the rule returns `'substitute`.

That is a different idempotence mechanism from Step 3c, which compared
operators to avoid eating its own output. Here the rule simply cannot find
the ingredients twice. Both work; neither keeps state.

#### On the exactness of the bounds

Because integers make `>1` and `>=2` equivalent, the normalisation loses
nothing — unlike `rewrite.txt` §2, no widening occurs and no compensating
`!=` predicates need asserting back. On a `Real` argument this arithmetic
would be wrong: `x>1.0` is not `x>=2.0`, and the rule would need the
widen-and-compensate approach the B-tree rule uses.

*(One inference: the exact contents and ordering of `REST` for `q5` were not
printed — this rule prints only `TRANSLATED`. That both bounds were present
follows from `lo` and `hi` both being set, since the guard requires it. Adding
`(print (list 'rest (rewrite-rest rw)))` would show the list directly.)*

### Where this rule is registered

Nowhere new. It inherits the three `ADD-REWRITER` calls from
[Step 1](#registration), which bound the **symbol** `REWRITE-SPY` to
`P_INTEGER.BAR->INTEGER` under `(+ -)`, `(+ +)` and `(- +)`. Redefining the
function is enough; the registration is unchanged.

If you are reproducing only this step, you still need those calls first:

```lisp
(add-rewriter (getfunctionnamed 'p_integer.bar->integer) '(+ +) 'rewrite-spy)
```

`(+ +)` alone suffices here, since the rule's own guard declines every other
pattern.

Two consequences of registering once and redefining repeatedly:

- **The name is now a misnomer.** `rewrite-spy` was apt for an observer; this
  rule folds range predicates into an index call. Renaming it would mean
  re-registering under the new symbol — a fair trade in real work, avoided
  here so the transcripts stay comparable across steps.
- **Guards are what actually scope the rule**, not the registration. It is
  attached to all three patterns but acts on one, because
  `(equal (rewrite-bpat rw) '(+ +))` rejects the others. Registration decides
  where a rule is *offered*; the rule itself decides where it *applies*.

### First attempt failed: generic vs resolvent

    Lisp 63> (setq barrange (getfunctionnamed 'bar_range))
    #[OID 1787 "BAR_RANGE"]

    Execution plan:
    (Q5->INTEGER _V2+) <-
    (NOT-VALID-TBR:
       (BAR_RANGE 2 3 X _V2))

`getfunctionnamed` with the **short** name returns the *generic* function,
OID 1787, printed bare. `create function` had returned OID 1788 with the
fully-typed name — the *resolvent*. Only a resolvent carries an
implementation, so the generic produced an invalid TBR predicate.

This is the same distinction that explains the `MBT-SELECT-RANGE` failure
documented in [`README.md`](README.md): OID 565 also prints bare. Both
working examples use the typed form:

```lisp
(CALL SQRTBF #[OID 1780 "REAL.MYSQRT->REAL"] 4.0 _V2+)
(CALL MBT-SELECT-RANGE #[OID 407 "FUNCTION.INTEGER.OBJECT.OBJECT.MBT-SELECT-RANGE->BOOLEAN"] …)
```

The fix is to look the resolvent up by its full name:

```lisp
(getfunctionnamed 'integer.integer.bar_range->integer.integer)
→ #[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]
```

`NOT-VALID-TBR:` is a usefully explicit label — it says the rule returned
something the optimizer could not accept as a TBR predicate, rather than
failing silently.

### It works

    AmosQL 64> create function q5() -> Bag of Integer as
      select bar(x) from integer x where x>1 and x<=3;
    Recompiling #[OID 1790 "Q5->INTEGER"]
    (TRANSLATED (CALL BAR-RANGE-FN
                  #[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]
                  2 3 X _V2))

    AmosQL 65> pc("q5");
    ----------------------------
    q5()->Bag of Integer

    Execution plan:
    (Q5->INTEGER _V2+) <-
    (CALL BAR-RANGE-FN #[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]
       2 3 X+ _V2+)

    AmosQL 65> q5();
    20
    30

**One operator.** No `HASH-FULL-SCAN`, no `NESTED-LOOP-JOIN`, no `GT--` or
`LE--` post-filters. Three predicates collapsed into a single access call,
and the answer is correct.

### The optimizer supplies the adornments

`TRANSLATED` was handed bare variables — `X _V2` — and the plan shows
`X+ _V2+`. So a rule states *which* variables a call produces and consumes
via `BND`, and the system derives the adornments itself. `rewrite.txt` §2's
example likewise shows bare `I` and `_V1`.

### Side by side with the document's example

| | `rewrite.txt` §2 target | This build, Step 5c |
|---|---|---|
| Absorbed | `i>1`, `i<=4` | `x>1`, `x<=3` |
| Emitted | `CALL MBT-SELECT-RANGE … 1 4 I _V1` | `CALL BAR-RANGE-FN … 2 3 X _V2` |
| Bounds | widened to closed, `>1`→`>=1` | normalised exactly, `>1`→`2` |
| Compensation | `!=1` asserted back | none needed (integers) |
| Implementation | C, unbound on this build | Lisp, working |

Structurally identical. The B-tree example from the documentation,
reconstructed with no C or Java toolchain, on a build where the original
routine cannot run.

## What the whole exercise establishes

- A TBR-rewrite rule is a Lisp function with a `REWRITE-` prefix, registered
  per (predicate function, binding pattern) with `ADD-REWRITER`.
- It receives `THIS`, `BPAT`, `BND`, `REST` and returns one of three control
  switches. `NIL` leaves the predicate untranslated and can break the query;
  `SUBSTITUTE` takes the default path; `SUCCESS` uses the rule's own
  `TRANSLATED`.
- `REST` is editable with `REWRITE-RETRACT` / `REWRITE-ASSERT`, by mutation,
  and those edits survive a `SUBSTITUTE` return.
- Rules fire repeatedly, so they must be idempotent by construction —
  design the output so it falls outside the rule's own trigger pattern.
- Foreign functions can be written entirely in ALisp, with no driver
  program, emitting whole tuples through `osql-result`.
- `TRANSLATED` must reference the **resolvent**, not the generic function.

Everything above runs under `ranksort`. Under `optmethod('exhaustive')` none
of it fires.
