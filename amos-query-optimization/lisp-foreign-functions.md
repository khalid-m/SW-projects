# Writing AMOS II foreign functions in ALisp

How to implement an AmosQL function in Lisp rather than C or Java, and how
to call AmosQL back from Lisp. This is the **callout** interface (AmosQL
calls your code) and the **callin** interface (your code calls AmosQL).

Source: [`../Amos-II-docs/external.pdf`](../Amos-II-docs/external.pdf) —
§3.2 "Implementing Amos II functions in ALisp", §3.2.1 "Multi-Directional
Foreign Functions in ALisp", and §2.2 "Calling Amos II from ALisp". Every
transcript below is real output from `AmosNT_floq` (Release 16 v11), per
[`CLAUDE.md`](CLAUDE.md)'s convention that behaviour is recorded only after
a run has shown it.

**`alisp.pdf`, also in `../Amos-II-docs/`, is not this.** It documents the
opposite direction — C functions callable *from* ALisp — and is irrelevant
if what you want is an AmosQL function implemented in Lisp.

## Why Lisp is the easiest route

`external.pdf` §3.2 states two things that make this the lowest-friction
foreign-function interface in the system:

> No driver program is needed for foreign Amos II functions implemented in
> ALisp.
>
> Function binding is not needed for foreign functions implemented in ALisp.

C and Java both require a driver program to register implementations before
AMOS II can find them. Lisp does not — you define the function and declare
it, in either order. **No compiler or toolchain is involved.**

§1 adds the general recommendation:

> It is often simpler to use the callout interface to ALisp or Java than to
> C. Those interfaces protect the user from doing illegal memory operations
> and the languages have built-in garbage collectors.

## The protocol

```lisp
(defun <fn> (fno <arg1>... <res1>...) . <body>)
```

| Part | Meaning |
|---|---|
| `fno` | **always first**; bound by the system to the AMOS II function object. §3.2: "usually not used, only for printing error messages." |
| `<arg1>…` | the function's arguments |
| `<res1>…` | the function's results |
| unbound positions | bound to the atom `*` |

The parameter names are positional — `external.pdf`'s own examples call the
first one `fno` in one function and `obj` in another.

### Emitting results

```lisp
(osql-result &rest tpl)
```

The Lisp counterpart of `a_emit` in the C interface. Its argument count must
equal **arity + width** — so a foreign function always emits the *whole
tuple*, including arguments it was handed.

That is not redundancy. An AmosQL function is a **relation**, and the
implementation produces members of it. `rewrite.txt` annotates a plan the
same way: `I ; argument of FOO returned`. Plan output agrees — a scan shows
`X+ _V2+`, both positions produced.

| Calls to `osql-result` | Result |
|---|---|
| none | empty bag — the function acts as a **filter**, with no error |
| one | a single tuple |
| many | a bag / stream of tuples |

The zero case is worth remembering: a foreign function that quietly emits
nothing is indistinguishable from a correct query over missing data.

## Declaration

Single-direction:

```sql
create function mysqrt(real x) -> real as foreign 'sqrtbf';
```

Multi-directional (§3.2.1) — one Lisp function per binding pattern:

```sql
create function mysqrt(real x) -> real as multidirectional
  ('bf' foreign 'sqrtbf')('fb' foreign 'sqrtfb');
```

**Single quotes**, not double.

§3.2.1's governing rule:

> For each binding pattern of a multi-directional foreign function you must
> implement separate Lisp functions.

`rewrite.txt` §3.1 extends the same syntax with cost functions and rewrite
rules per direction:

```sql
create function fie(integer x)->real y as multidirectional
        ("bf" foreign "fiebf" cost "fiebfcost" rewriter "fiebf")
        ("fb" foreign "fiefb" cost "fiefbcost" rewriter "fiefb");
```

### Tuple-valued results

```sql
create function bar_range(Integer lo, Integer hi)
  -> Bag of <Integer x, Integer y> as foreign 'bar-range-fn';
```

`Bag of <…>` is accepted, though §3.2 writes tuple results without the `Bag
of` prefix. Arity 2 + width 2 means each emit takes four arguments.

## Worked example

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

    AmosQL 52> select x from number x where mysqrt(x)=4.0;
    WARNING: Coercing argument in call to mysqrt(Real)->Real
    16.0

Two things to read here.

**Two tuples from one call.** `sqrtbf` emits both roots, so the forward call
returns a bag.

**Different code per direction.** `16.0` comes from `sqrtfb`'s `(* r r)`.
Binding the result instead of the argument selected a different Lisp
function — the dispatch that multi-directional functions exist for.

Note the positional order never changes: `sqrtfb` computes `x` from `r`, yet
still emits `⟨x, r⟩`. Tuple order follows the signature, not the direction.

## Calling AmosQL from Lisp

§2.2's embedded-query interface. AmosQL variables written `:v` inside an
`osql` string map to Lisp variables prefixed **`AMOS_`**:

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

`osql-let` declares the interface variables with their AMOS II types, which
§2.2 says avoids inefficient late binding. `osql-declare` does the same
globally; §2.2 warns not to call it *inside* an `osql-let`, since the
declaration would then be local and lost on exit.

**A miss leaves the variable `NIL`** rather than erroring — so `(cond
(AMOS_v …))` is a valid guard.

**This works from inside a foreign function.** §1 sanctions it — "the system
furthermore allows the callin interface to be used in the foreign functions,
which gives great flexibility" — and it does work in practice, including
inside a loop. A worked example that scans a key range this way is in
[`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md)
Step 5b.

### Performance note

§2.2 warns the interface "is optimized for flat Amos II function calls."
Nested queries and ad hoc `select` statements are dynamically optimized on
every execution, which is very slow. A flat call like `select bar(:i) into
:v;` is the good case.

## Gotchas

**Overloading a built-in name silently shadows your code.** Naming a
function `sqrt`, which AMOS II already defines, registers an *overload* —
`#[OID 1778 "REAL.SQRT->REAL"]` — not a replacement. Calls then resolve to
the built-in, and redefining your Lisp function changes nothing, which looks
like a caching problem. It is not; your code never ran. **Use a name nothing
else owns when testing.**

**Coercion warnings are resolution signals.** `WARNING: Coercing argument in
call to mysqrt(Real)->Real` means the query's variable type did not match
the parameter type — `Number` against `Real` here. Harmless in itself, but
it tells you which overload was selected and that argument types are driving
resolution. That is exactly the situation where silent shadowing happens.

**Generic vs resolvent.** `getfunctionnamed` with a short name returns the
**generic** function, which prints bare and carries no implementation:

    (getfunctionnamed 'bar_range)   →  #[OID 1787 "BAR_RANGE"]

The callable **resolvent** prints fully typed and is what `create function`
returns:

    #[OID 1788 "INTEGER.INTEGER.BAR_RANGE->INTEGER.INTEGER"]

Anything that needs a real implementation needs the resolvent. Look it up by
the full name: `(getfunctionnamed 'integer.integer.bar_range->integer.integer)`.

**`external.pdf`'s code examples contain errors.** Its first `sqrtbf` emits
`(osql-result 0.0 0.0)` where §3.2.1's corrected version has
`(osql-result x 0.0)`; its `sqrt2` references a variable it never binds.
Treat the prose as authoritative and the code as approximate.

## Related

- [`query-rewrite/building-a-rewrite-rule.md`](query-rewrite/building-a-rewrite-rule.md)
  — uses these functions as the target of a TBR-rewrite rule, collapsing
  three predicates into one call to a Lisp range routine.
- [`query-rewrite/README.md`](query-rewrite/README.md) — the rewrite
  mechanism itself, and why `mbtree` range access fails on this build.
- [`tutorial-index-execution-plans.md`](tutorial-index-execution-plans.md) —
  reading `pc()` plans, where the `CALL` forms these functions produce show
  up.
