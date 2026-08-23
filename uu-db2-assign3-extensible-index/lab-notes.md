# Run Log — Assignment 3 (Extensible Database Indexing)

Environment: **Amos II Release 16, v11** (assignment doc examples were written against an
older release, but the behavior matches).

## Session transcript

```
AmosQL 1>  create function winequalitysamples(Number sp)-> Vector of Number wq as
stored;
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.006 s

AmosQL 2>  create_index("winequalitysamples", "wq", "MBTREE", "multiple");
{NIL,NIL}
0.018 s

AmosQL 3>  indexes(#'winequalitysamples');
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],0,"hash","unique"}
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],1,"mbtree","multiple"}
0.043 s

AmosQL 3> drop_index('winequalitysamples', 'sp');
0
0.015 s

AmosQL 4> drop_index('winequalitysamples', 'wq');
Trying to remove last index on NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER
0.003 s

AmosQL 4> indexes(#'winequalitysamples');
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],1,"mbtree","multiple"}
0.028 s

AmosQL 4> pc(#'winequalitysamples');
----------------------------
winequalitysamples(Number)->Vector of Number

Execution plan:
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.025 s
AmosQL 4>
```

## What happened, step by step

1. `create function winequalitysamples(...) as stored` — defines a stored function
   `sp -> wq`. AMOS automatically adds a default unique **hash** index on the first
   argument (`sp`), since stored functions need a key to look up by.
2. `create_index(..., "wq", "MBTREE", "multiple")` — adds a second, non-unique **MBTREE**
   index (a metric/M-tree, suited to vector similarity search) on `wq`. Now two indexes
   exist: `hash` on `sp` (position 0), `mbtree` on `wq` (position 1).
3. `indexes(#'winequalitysamples')` confirms both.
4. `drop_index('winequalitysamples', 'sp')` — removes the hash index on `sp`. Succeeds
   because `wq`'s mbtree index remains, so the function still has at least one index.
5. `drop_index('winequalitysamples', 'wq')` — refused ("Trying to remove last index"):
   AMOS always requires at least one index on a stored function, and `wq`'s mbtree is now
   the only one left.
6. `indexes(...)` confirms only the mbtree index on `wq` (position 1) survives.
7. `pc(#'winequalitysamples')` prints the execution plan — discussed below.

## Explaining the execution plan

```
Execution plan:
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.025 s
```

**Line 1 — the function call header**
```
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
```
Names the function being planned: `winequalitysamples(Number)->Vector of Number`, called
with `sp` bound (`-`) as input and `wq` unbound (`+`) as the output being produced. The
`<-` means "is computed by the plan below."

**Lines 2-3 — the physical operator**
```
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
```
This is the single physical algebra operator executing the call. Per the general pattern
`<INDEX>-FULL-SCAN`: **iterate over the entire MBTREE index, checking every entry**, rather
than jumping directly to the entries matching `sp`. It takes `sp` bound and emits `wq` for
each match found by scanning.

**Why FULL-SCAN and not INDEX-GET/INDEX-SCAN**, even though an index exists: the hash index
on `sp` was dropped, leaving only the mbtree index on `wq`. An MBTREE is built over `wq`
values (for vector-similarity lookups), not over `sp` — it offers no efficient way to seek
"give me the row where `sp` = X." So even though *an* index exists, it isn't usable for
this query's bound/unbound pattern, and the engine falls back to walking the whole tree and
checking each entry's `sp` value one by one — i.e. a full scan.

**Bottom line:** after dropping the index on `sp`, `winequalitysamples` no longer scales —
every call does O(n) work regardless of table size, because the only remaining index
(mbtree on `wq`) isn't usable for looking up by `sp`. Re-adding a hash/unique index on `sp`
would be expected to restore a `HASH-INDEX-GET` plan, which scales.
