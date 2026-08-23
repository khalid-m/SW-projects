# Tutorial: Index Types and Execution Plans in AMOS II

Goal: build a small stored function, look at its execution plan in different calling
directions, and see the three physical scan operators AMOS II uses for indexes:

- **`<INDEX>-FULL-SCAN`** — walks every entry in the index, checking each one against
  the query. Used when the bound argument isn't the indexed one. Does not scale.
- **`<INDEX>-INDEX-SCAN`** — jumps straight to the matching key(s) in a *multiple*
  (non-unique) index, then returns all tuples for that key. Scales as long as each key
  doesn't map to too many rows (low multiplicity).
- **`<INDEX>-INDEX-GET`** — jumps straight to the single tuple matching a *unique* key.
  Scales well (O(1)-ish for hash, O(log n) for B-tree).

Everything below is written to be pasted into `Javaamos`/`amos2` one statement at a
time (per `Javaamos N>` prompt) — not syntax-checked against your exact AMOS II
release, fix as needed while running.

> **Naming convention:** operators are named `<STRUCTURE>-<OPERATION>` — the first
> part names the *physical structure* being read (`HASH`, `BTREE`, ...), the second
> names *how* it's read (`FULL-SCAN`, `INDEX-SCAN`, `INDEX-GET`). A stored function's
> tuples live *inside* whatever index structure was built on it — there's no separate
> generic "table" storage underneath. So `HASH-FULL-SCAN` doesn't mean "scan a table
> using a hash index"; it means "walk every entry of this hash-organized structure,
> start to finish," which — since that structure *is* the function's only storage —
> is equivalent to a full table scan. If the same function instead had a B-tree
> index, the same "visit everything" behavior would show up as `BTREE-FULL-SCAN`.
> Keep this in mind for both Part 1 (`HASH-INDEX-GET`) and Part 2 (`HASH-FULL-SCAN`)
> below: same physical hash table both times, different traversal strategy.

---

## Part 1 — HASH-INDEX-GET: unique key lookup (fast direction)

This is the example we already ran. A unique hash index is created automatically on
the first (only) argument of a stored function.

```
create function asci_map(Charstring ch) -> Number n as stored;
set asci_map('A') = 65;
set asci_map('B') = 66;

/* Forward direction: ch is bound, n is produced -> uses the hash index directly */
asci_map('A');

pc("asci_map");
```

Confirmed against a real run — `asci_map('A')` returns `65`, and `pc("asci_map")`
prints:

```
Execution plan:
(CHARSTRING.ASCI_MAP->NUMBER CH- N+) <-
(HASH-INDEX-GET #[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"] CH- N+)
#[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"]
```

`CH-` (bound) / `N+` (produced) — the hash table computes `hash(ch)`, jumps to the
bucket, done. O(1) regardless of how many entries exist.

### Reading the plan line by line

**Line 1 — the call being planned:**
```
(CHARSTRING.ASCI_MAP->NUMBER CH- N+) <-
```
This is the call `asci_map('A')`. `CHARSTRING.ASCI_MAP->NUMBER` is the function's
fully-qualified internal name (argument type, function name, result type). `CH-`
means the argument `ch` is **bound** (you supplied `'A'`); `N+` means the result `n`
is **unbound/produced** (what the call computes — `65`). The `<-` reads as "is
computed by" — everything below it is *how* this call is physically carried out.

**Line 2 — the one physical operator implementing it:**
```
(HASH-INDEX-GET #[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"] CH- N+)
```
Read as: "run a HASH-INDEX-GET on the index object `OID 1514`", which is `asci_map`'s
own storage — the function and the index it's reading from are the *same*
object (unlike `char_for_code`, which was a derived function reading someone else's
index). At runtime this means: compute `hash('A')`, jump directly to that bucket,
and read off the stored `n` value. No other entries are touched — that's what makes
this O(1)-ish regardless of how many `(ch, n)` pairs exist, in contrast to the
`HASH-FULL-SCAN` in Part 2, which had to visit every entry.

**Line 3 — the object banner, not part of the plan:**
```
#[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"]
```
Same role as in Part 2's example: this is AMOS's standard footer confirming *which*
function object `pc("asci_map")` displayed a plan for — here it happens to be the
same OID (`1514`) that also appears inside the `HASH-INDEX-GET` line, because
`asci_map` is both the function being called *and* the index being read. It is not
an extra execution step.

---

## Part 2 — HASH-FULL-SCAN: reverse direction on the same index

Same stored data, but now we ask the question the index *wasn't* built for: given a
code, find the character. No index exists on `n`, so the engine has to walk the whole
`ch`-keyed hash table and check `n` on every entry.

```
create function char_for_code(Number n) -> Charstring ch as
  select ch from Charstring ch where asci_map(ch) = n;

char_for_code(65);

pc("char_for_code");
```

Confirmed against a real run — `char_for_code(65)` returns `"A"`, and
`pc("char_for_code")` prints:

```
Execution plan:
(NUMBER.CHAR_FOR_CODE->CHARSTRING N- CH+) <-
(HASH-FULL-SCAN #[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"] CH+ N-)
#[OID 1517 "NUMBER.CHAR_FOR_CODE->CHARSTRING"]
```

Same physical hash table as Part 1, but now used as a full scan: every stored `(ch,
n)` pair is visited and checked against `n`, one at a time. O(entries), no matter how
selective the filter is.

### Reading the plan line by line

**Line 1 — the call being planned:**
```
(NUMBER.CHAR_FOR_CODE->CHARSTRING N- CH+) <-
```
This *is* the call `char_for_code(65)`. `NUMBER.CHAR_FOR_CODE->CHARSTRING` is the
function's fully-qualified internal name (argument type, function name, result type
— same convention as `CHARSTRING.ASCI_MAP->NUMBER`). `N-` means the argument `n` is
**bound** (you supplied `65`); `CH+` means the result `ch` is **unbound/produced**
(what the call computes — `"A"`). The `<-` reads as "is computed by" — everything
below it is *how* this call is physically carried out.

**Line 2 — the one physical operator implementing it:**
```
(HASH-FULL-SCAN #[OID 1514 "CHARSTRING.ASCI_MAP->NUMBER"] CH+ N-)
```
Read as: "run a HASH-FULL-SCAN over the index object `OID 1514`" — which is
`asci_map`'s own hash index, not something belonging to `char_for_code`. That's the
key point: `char_for_code` is a *derived* function with no storage of its own; its
entire plan is just this one scan over `asci_map`'s storage. At runtime this means:
iterate every stored `(ch, n)` pair in `asci_map`'s hash table; for each pair, check
whether its `n` equals the bound value `65`; when it matches, emit that pair's `ch`
(here, `"A"`). So yes — the call is executed *as* a `HASH-FULL-SCAN` over
`asci_map`'s index; there's nothing else in the plan.

**Line 3 — the object banner, not part of the plan:**
```
#[OID 1517 "NUMBER.CHAR_FOR_CODE->CHARSTRING"]
```
This is AMOS's standard footer, printed after any command that returns/refers to an
object — it's just restating "the function this plan belongs to is object OID `1517`,
named `NUMBER.CHAR_FOR_CODE->CHARSTRING`" (the same OID printed back when
`char_for_code` was created). It identifies *which* function `pc(...)` was showing
you a plan for; it isn't a step of the plan itself, the same way `#[OID 1514 ...]`
on the line above just identifies *which* index object the scan reads from.

You can also enumerate every stored pair at once (both sides unbound) — same
full-scan mechanism, just no filter to apply:

```
create function asci_pairs() -> (Charstring ch, Number n) as
  select ch, n from Charstring ch, Number n where asci_map(ch) = n;

asci_pairs();
pc("asci_pairs");
```

---

## Part 3 — HASH-INDEX-SCAN: a *multiple* (non-unique) hash index

`HASH-INDEX-GET` needs a **unique** key. When several rows legitimately share the same
key value, you instead build a *multiple* index, and the matching operator becomes
`HASH-INDEX-SCAN`: still a direct jump to the key's bucket (fast), but it then has to
emit potentially more than one matching tuple.

New example — people and the department they work in (many people per department):

```
create type Person;
create function name(Person p) -> Charstring as stored;
create function dept(Person p) -> Charstring d as stored;

create Person(name, dept) instances
  :p1 ("Alice", "Engineering"),
  :p2 ("Bob",   "Engineering"),
  :p3 ("Carol", "Sales");

/* Index the RESULT of dept (a Charstring), non-unique, so many people can
   map to the same department string */
create_index("dept", "d", "hash", "multiple");

select p from Person p where dept(p) = "Engineering";

pc("dept");
```

Confirmed against a real run:

```
AmosQL> select p from Person p where dept(p) = "Engineering";
#[OID 1540]
#[OID 1539]
0.05 s
AmosQL> pc("dept");
----------------------------
dept(Person)->Charstring

Execution plan:
(PERSON.DEPT->CHARSTRING P- D+) <-
(HASH-INDEX-GET #[OID 1537 "PERSON.DEPT->CHARSTRING"] P- D+)
#[OID 1537 "PERSON.DEPT->CHARSTRING"]
```

**This is not the plan for the query we ran.** Its binding pattern is `P- D+`
(`p` bound → `d` produced), which is `dept`'s *own default/forward* direction — i.e.
the plan for calling `dept(:p1)`, not for our query `dept(p) = "Engineering"`, which
binds `d` and asks for `p` (pattern `D- P+`). `pc("dept")` always shows the plan for
*that function's own* default binding pattern, not for whatever query you last typed
that happens to call it — same lesson as Part 2's `pc()` caveat. To inspect a
specific query's own plan, that query has to be the body of a named function (as we
did with `char_for_code`) — which is exactly what `people_in_dept` below does.

There's also a structural reason `dept` has *two* possible directions to plan for
at all — check what indexes actually exist on it:

```
AmosQL> indexes(#'dept');
{#[OID 1518 "P_PERSON.DEPT->CHARSTRING"],0,"hash","unique"}
{#[OID 1518 "P_PERSON.DEPT->CHARSTRING"],1,"hash","multiple"}
```

This shows `dept` actually has **two independent hash indexes**, one per parameter
position, not one index read two different ways:

- **Position 0 (`p`, the argument) — `"hash","unique"`.** This is the *default*
  index AMOS automatically creates on every stored function's argument. Since each
  `Person` has exactly one `dept`, a lookup by `p` is inherently unique. This is the
  index `pc("dept")` reported above — forward direction, `HASH-INDEX-GET`.
- **Position 1 (`d`, the result) — `"hash","multiple"`.** This is the index *we*
  explicitly added with `create_index("dept", "d", "hash", "multiple")`. Since many
  people can share a department, a lookup by `d` can return several people. This is
  the index the *reverse* direction (`people_in_dept`, below) actually uses.

So "the same function can be evaluated in different directions" isn't just an
abstract idea — concretely, each direction is backed by its *own* physical index
with its *own* uniqueness constraint, and the optimizer picks whichever index
matches the binding pattern of the specific call being planned.

To see the plan for the *reverse* lookup itself (the one we actually ran), define it
as a named function first:

```
create function people_in_dept(Charstring d) -> Person p as
  select p from Person p where dept(p) = d;

pc("people_in_dept");
```

Confirmed against a real run — this is the plan for binding pattern `D- P+` (department
bound, people produced), which is where the "multiple index" behavior actually shows up:

```
Execution plan:
(CHARSTRING.PEOPLE_IN_DEPT->PERSON D- P+) <-
(HASH-INDEX-SCAN #[OID 1537 "PERSON.DEPT->CHARSTRING"] P+ D-)
#[OID 1543 "CHARSTRING.PEOPLE_IN_DEPT->PERSON"]
```

So the pattern holds up exactly as described at the top of this tutorial, once you
look at the *right* binding direction — but note both plan lines quote the **same** OID,
`1537 "PERSON.DEPT->CHARSTRING"`, as the operator's argument, for *both* directions
(`HASH-INDEX-GET` in the forward plan, `HASH-INDEX-SCAN` here). That OID is `dept`
the function object itself, not a specific one of its two indexes — compare with
`indexes(#'dept')` above, where the two actual index descriptors live under a
*different* OID (`1518 "P_PERSON.DEPT->CHARSTRING"`), distinguished only by their
position field (`0` vs `1`). So the plan operator names *which function's storage*
it's reading, and internally selects *which of that function's registered indexes*
(position 0's unique index, or position 1's multiple index) matches the query's
binding pattern — that choice doesn't show up as a different OID in the plan, only
as the different operator name (`GET` vs `SCAN`).

Mechanically: for `HASH-INDEX-SCAN` here, `d` (the key) is bound, `p` (potentially
more than one match per key) is produced. AMOS jumps straight to the
`"Engineering"` bucket (no full scan needed) but then has to walk that bucket's
*own* list of matches, since a "multiple" key can map to more than one tuple —
that's the difference from `HASH-INDEX-GET`'s "exactly one tuple, done" behavior
in Part 1.

This also resolves the earlier confusion: `HASH-INDEX-GET` vs. `HASH-INDEX-SCAN`
*is* determined by which side of the index you're querying through, exactly as
described at the top of this tutorial — it just wasn't visible when we called
`pc("dept")` directly, because that
showed `dept`'s own forward direction (`p-`, `d+`), not the reverse query we'd
actually run. Lesson confirmed twice now (Part 2 and Part 3): `pc("<name>")` always
shows *that function's own* default binding pattern — to inspect a specific
query's plan, that exact query has to be the body of some named function.

---

## Part 4 — MBTREE: an ordered, multi-value index

Extend the `Person` example with an `age`, and index it with `mbtree` — an ordered
tree index — instead of `hash`. As in Part 3, the result parameter needs a name
before `create_index` can refer to it:

```
create function age(Person p) -> Integer a as stored;

set age(:p1) = 30;
set age(:p2) = 25;
set age(:p3) = 40;

create_index("age", "a", "mbtree", "multiple");
```

```
AmosQL> indexes(#'age');
{#[OID 1524 "P_PERSON.AGE->INTEGER"],0,"hash","unique"}
{#[OID 1524 "P_PERSON.AGE->INTEGER"],1,"mbtree","multiple"}
```

Same shape as `dept` in Part 3: position `0` (`p`, the argument) keeps its
automatic unique hash index; position `1` (`a`, the result) gets the `mbtree`
index just created, non-unique since several people can share an age.

**Equality lookups work, and use the `mbtree` index**, once queried in the
direction that actually reads it (`a` bound → `p` produced — same `pc()` caveat as
Part 3, so the query needs to be wrapped in a named function to inspect its own
plan rather than `age`'s default direction):

```
create function person_with_age(Integer a) -> Person p as
  select p from Person p where age(p) = a;

pc("person_with_age");
```
```
Execution plan:
(INTEGER.PERSON_WITH_AGE->PERSON A- P+) <-
(MBTREE-INDEX-SCAN #[OID 1523 "PERSON.AGE->INTEGER"] P+ A-)
```

This is the same behavior as Part 3's `HASH-INDEX-SCAN`: jump to the matching
key's position in the index, return however many tuples share it. So `mbtree`
works as an ordinary multi-value index for equality.

**Range predicates (`>`, `<`) do not work on this index**, even though `mbtree` is
an ordered structure:

```
AmosQL> select p from Person p where age(p) > 28;
No foreign implementation: NIL
```

The error means the optimizer has no physical operator registered to turn a `>`/`<`
predicate on an `mbtree`-indexed argument into a range scan — there's simply
nothing to call. So the accomplished, verified result for this index type is:
**equality lookups (`=`) are supported via `MBTREE-INDEX-SCAN`; range comparisons
(`>`, `<`) are not**, at least not without further setup beyond a plain
`create_index` call. This is a useful contrast with the conceptual model at the
top of this tutorial: an ordered index *can* in principle serve range queries, but
whether a specific index type actually does so is something to verify with
`pc()`/by running the query — not something to assume from the index type's name
or its underlying structure.

---

## Cheat-sheet: which operator shows up when

| You ask for...                                      | Index exists on...      | Operator you'll see    |
|-------------------------------------------------------|--------------------------|--------------------------|
| exact match on the indexed, **unique** argument        | that argument (unique)   | `<TYPE>-INDEX-GET`      |
| exact match on the indexed, **non-unique** argument    | that argument (multiple) | `<TYPE>-INDEX-SCAN`     |
| a range (`<`, `>`, `between`)                          | ordered index (e.g. `mbtree`) — support isn't guaranteed; verify with `pc(...)` | `<TYPE>-INDEX-SCAN` if supported, otherwise no plan at all (`No foreign implementation`) |
| exact match / range on a **non-indexed** argument      | (none, or wrong side)    | `<TYPE>-FULL-SCAN`      |
| calling a Java-implemented function                    | n/a                       | `CALL`                  |

Use `pc("<functionname>")` after every `create_index` / `drop_index` +
`recompile("<functionname>")` to see which one you actually got — the optimizer
decides based on what's bound, not on intent, and an index type supporting one
predicate (`=`) doesn't guarantee it supports another (`>`/`<`), as Part 4 shows.
