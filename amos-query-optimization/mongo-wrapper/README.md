# The AMOS II MongoDB wrapper

A complete, production-shaped **wrapper** that makes MongoDB collections
queryable from AmosQL — including pushing predicates down into MongoDB rather
than fetching everything and filtering locally.

Authored at UDBL, Uppsala: Khalid Mahmood (C interface, 2013) and Tore Risch
(query processor and optimizer extensions, 2014).

> **Status: unverified, and blocked.** This page is a **reading of the
> source**, not a run. Per [`../CLAUDE.md`](../CLAUDE.md)'s convention, treat
> every behavioural claim below as *what the code says it does*, not as
> observed output.
>
> The wrapper is installed in the tested build at
> `AmosNT_floq\wrappers\Mongo`, but **it cannot be loaded.**
> `load_extension("Mongo_wrapper")` needs a DLL built from `MongoForeign.c`
> against `amos2.lib` and `mongo_driver.lib`, and no C toolchain is available
> in this environment. Every `.amosql` file here begins with that
> `load_extension` call, so nothing downstream of it runs — not the
> interface, not `new_wrapper("Mongo")`, not the optimizer registrations.
>
> **This is the one component in the repo that Lisp cannot rescue.** The
> TBR-rewrite work in [`../query-rewrite/`](../query-rewrite/) was blocked the
> same way and turned out to have a Lisp-only path —
> [`../lisp-foreign-functions.md`](../lisp-foreign-functions.md) documents
> foreign functions needing no compiler. That does not help here: the
> MongoDB C driver is a native library, and nothing in ALisp can speak the
> wire protocol to a MongoDB server.
>
> See [Open: what a working build would settle](#open-what-a-working-build-would-settle).

## Why it matters to this repo

Everything else here studies AMOS II's optimizer from the outside — reading
`pc()` plans, timing `dynprogsort`, building a toy rewrite rule. This
directory is the real thing: **a wrapper that translates AMOS II predicates
into a foreign query language**, which is the use case `rewrite.txt` §1 opens
by describing.

It is also the working example of predicate pushdown that
[`../cost-based-vs-rule-based-optimization.md`](../cost-based-vs-rule-based-optimization.md)
compares Polars against. Where Polars pushes a filter into a Parquet scan,
this pushes an AmosQL conjunction into a MongoDB filter document.

## The four layers

`rewrite.txt` §1 says a wrapper has two subsystems, an **interface** and a
**translator**. This one has both, plus the AmosQL glue between them:

| Layer | File | Role |
|---|---|---|
| **Interface (C)** | `MongoForeign.c` | talks to the MongoDB C driver; BSON ⇄ AMOS II record conversion |
| **Interface (AmosQL)** | `mongo_interface.amosql` | declares those C functions; builds derived convenience functions on them |
| **Wrapper / mediator glue** | `mongo_query_processor.amosql` | `new_wrapper`, connections, source predicates, mapped types |
| **Translator (Lisp)** | `mongo_optimizer.lsp` | extractor, cost model, finalizer — the optimizer extensions |

**Deep dive:** [`query-translation.md`](query-translation.md) walks the last
two rows function by function — how an AmosQL conjunction is split, priced,
and turned into a BSON filter document.

Two further files sit outside that stack:

| File | Role |
|---|---|
| `index.osql` | a Mexima-style extensible index whose storage is a MongoDB collection |
| `MongoWrapper.osql` | an earlier standalone meta-data file, superseded by `mongo_interface.amosql` |
| `master.amosql` | the loader — reads the interface then the query processor |
| `readme.txt` | **setup guide** — build the driver, install MongoDB 2.4.8, start `mongod`, run a tutorial session |
| `readme2.txt` | generic build instructions for **any** AMOS II C extender; not MongoDB-specific. Renamed from `readme.txt` to leave that name to the setup guide. |
| `examples/test.osql` | a longer worked session: inserts, queries, custom `_id`s, bulk insert, error cases |

## Loading

```
master.amosql
  ├─ mongo_interface.amosql        → load_extension("Mongo_wrapper")
  └─ mongo_query_processor.amosql  → new_wrapper("Mongo")
                                     load_lisp("mongo_optimizer.lsp")
                                     set_extractor / set_finalizer / set_costmodel
```

The last three lines are the whole registration:

```sql
set_extractor('Mongo', 'mongo-extractor');
set_finalizer('Mongo', 'mongo-finalizer');
set_costmodel('Mongo', 'mongo-costmodel');
```

Compare `ADD-REWRITER` in
[`../query-rewrite/building-a-rewrite-rule.md`](../query-rewrite/building-a-rewrite-rule.md):
same idea — name a Lisp function to the optimizer — but registered **per data
source** rather than per (predicate function, binding pattern).

## The interface layer

### C foreign functions

`MongoForeign.c` implements eight, using the `a_callcontext` callout API:

| C function | AmosQL declaration |
|---|---|
| `mongo_connectFB` | `mongo_connect(Charstring host) -> Integer` |
| `mongo_disConnectBF` | `mongo_disconnect(Number) -> Boolean` |
| `mongo_addBBBBF` | `mongo_add(conn, db, coll, Record) -> Literal` |
| `mongo_delBBBBF` | `mongo_del(conn, db, coll, Record) -> Boolean` |
| `mongo_queryBBBBF` | `mongo_query(conn, db, coll, Record q) -> Bag of Record` |
| `mongo_add_batchBBBBBF` | bulk insert |
| `mongo_createIndexBBBBBF` | create a MongoDB index |
| `mongo_run_cmdBBBF` | run an arbitrary Mongo command |

**Read the names.** `mongo_queryBBBBF` — four bound arguments, one free
result. The binding pattern is encoded in the C identifier, and again in the
AmosQL declaration's adornment string:

```sql
as foreign 'mongo_query----+';
```

`-` bound, `+` free. That is the same adornment idea as the `'(+ -)` lists
passed to `ADD-REWRITER` elsewhere in this repo, and as the `'bf'`/`'fb'`
strings in multidirectional declarations — three notations, one concept.

Results are emitted one at a time with `a_bind` followed by `a_result(cxt)` —
the generator protocol, the C counterpart of `osql-result` in
[`../lisp-foreign-functions.md`](../lisp-foreign-functions.md).

Roughly half the C file is BSON ⇄ AMOS II conversion: `bson_data_to_record`,
`bson_data_to_array`, `record_to_bson`, `array_to_bson`.

### Derived functions on top

`mongo_interface.amosql` shows the pattern the whole system leans on — a thin
C layer, then everything else in AmosQL:

```sql
create function mongo_get(Number conn_no, Charstring database,
                          Charstring collection, Object k) -> Record
  as mongo_query(conn_no, database, collection, {"_id": k});
```

`mongo_dropIndex`, `mongo_collStats`, `mongo_count`, `mongo_dbStats` and
friends are all one-liners over `mongo_run_cmd`. Only `mongo_replace` is
substantial, and it carries an honest comment about MongoDB's lack of
transactions:

```sql
begin mongo_del(...);
      /* The database may be inconsistent here
         because of lack of transactions in MongoDB */
      return mongo_add(conn_no, database, collection, new);
end;
```

## Source predicates and mapped types

`import_mongo_collection` turns a MongoDB collection into an AMOS II type.
The generated **source predicate** is the interesting part:

```sql
create function <coll>_sourcepred() -> Bag of (Object id key, Record v key)
  as multidirectional
     ('fb' key select r['_id'] from Record r where
                 r in mongo_query(..., v))
     ('bf' key select mongo_get(..., id))
     ('ff' select mongo_kvp(...));
```

Three binding patterns, three access strategies:

| Pattern | Situation | Strategy |
|---|---|---|
| `bf` | id known | fetch that one document by `_id` |
| `fb` | value known | query by content |
| `ff` | neither | scan the whole collection |

This is the multi-directional foreign function of Litwin & Risch 1992 §5,
applied to a document store: one logical relation, several physical access
paths, the optimizer choosing between them by cost.

Around it, `import_mongo_collection` also generates an attribute accessor
(`vref`), a replacer, a property setter, and a destructor — so Mongo
documents appear as ordinary AMOS II objects with a type.

## Setup, and two stale examples

`readme.txt` is the MongoDB-specific setup guide:

1. `installMongo.cmd` — compile the MongoDB driver and the wrapper.
2. Download MongoDB **2.4.8** (a 2013 release) from a UDBL-hosted URL.
3. Create `%HOMEDRIVE%%HOMEPATH%\data\db`.
4. Start the server: `mongod --dbpath …/data/db`.
5. In another shell: `amos2 MongoWrapper.dmp`.

Two things in that list are worth noticing.

**`installMongo.cmd` is not in this directory.** It is the script that would
produce the DLL, and it is exactly what the load blocker above needs. If it
exists in the installed copy at `AmosNT_floq\wrappers\Mongo`, the Tier 1
items below may be closer than they look.

**Step 5 starts from a saved image, not from source.** `MongoWrapper.dmp` is
an AMOS II database dump with the wrapper already loaded — see
[Tier 1](#tier-1--needs-the-dll-no-mongodb-server).

### The examples disagree with the shipped interface

Both example files predate `mongo_interface.amosql` (last revised
2014-03-29), and the API moved underneath them. Running either as written
would produce `Cannot resolve function call`.

| `readme.txt` | `examples/test.osql` | `mongo_interface.amosql` (current) |
|---|---|---|
| `mongo_put(c, "tutorial.person", r)` | `mongo_add(c, "tutorial", "person", r)` | `mongo_add(c, db, coll, r)` |
| `mongo_get(c, "tutorial.person", q)` | `mongo_get(c, "tutorial", "person", q)` | **`mongo_query(c, db, coll, q)`** |
| — | `mongo_bulk_add(c, db, coll, v)` | `mongo_add_batch(c, db, coll, v)` |
| — | `mongo_collections(c, db)` | `mongo_collNameSpaces(c, db)` |

Three generations are visible:

1. **`readme.txt`** — oldest. `mongo_put`, and database and collection
   combined into one `"db.collection"` namespace string.
2. **`examples/test.osql`** — database and collection split into separate
   arguments, `mongo_put` renamed to `mongo_add`. Still calls `mongo_get`
   with a **filter record**.
3. **`mongo_interface.amosql`** — filter queries become `mongo_query`, and
   the name `mongo_get` is reused for lookup **by key**:

   ```sql
   create function mongo_get(Number conn_no, Charstring database,
                             Charstring collection, Object k) -> Record
     as mongo_query(conn_no, database, collection, {"_id": k});
   ```

The RCS log in `mongo_interface.amosql` dates that last change precisely:

```
Revision 1.7  2014/01/18  torer
  mongo_get() -> mongo_query()
```

So `examples/test.osql` is from before 2014-01-18. The rename is the
awkward kind — `mongo_get` still exists and still takes four arguments, so
a stale call fails on the *type* of the fourth (a `Record` where an `Object`
key is expected) rather than on a missing name.

**Useful anyway.** `test.osql` is the best description here of what the
wrapper is for, and its content survives the rename:

```sql
set :c = mongo_connect("127.0.0.1");
mongo_add(:c, "tutorial", "person", {"Name": "Ville", "age": 54});
mongo_add(:c, "tutorial", "person", {"_id":"abc", "Name": "Ulla", "age": 55});
```

It shows that `_id` may be supplied by the caller as an integer, string or
real; that a record can be bound into an AmosQL variable and its `_id`
extracted with `:kalle["_id"]`; and that queries against a non-existent
database or collection are expected to return empty rather than error. The
file ends on an explicit to-do — *"Make sure errors with proper error
messages are raised when mongodb raises error"* — so error handling was
unfinished at the time of writing.

## The translator: `mongo_optimizer.lsp`

Three functions, matching the three registrations.

### Extractor — what can MongoDB handle?

```lisp
(defun mongo-extractor (sp predl bnd) …)
```

Given the source predicate `sp`, the surrounding conjunction `predl`, and the
bound variables `bnd`, it returns a split:

- **`:preds`** — the source predicate, plus record-attribute accesses on its
  variable, plus comparisons over those attributes whose operands are bound.
- **`:remaining`** — everything else, left for AMOS II to evaluate.

That split is the direct answer to the complaint `rewrite.txt` §1 raises
about the capabilities model:

> If you have a source that can handle certain capabilities but not all
> combinations of these in a conjunction, the query optimizer will fail

An extractor does not declare fixed capabilities. It inspects the actual
conjunction and claims exactly the subset it can serve, every time.

### Cost model

```lisp
(defun mongo-costmodel (expression bnd)
  (let ((filter (expression-filter expression)))
    (cond ((null (cdr filter))              (list 100000 100000))
          ((not (is-executable …))          nil)
          ((has-mongo-equality filter bnd)  (list 10 10))
          ((has-mongo-comparison filter bnd)(list 100 100))
          (t                                (list 1000 1000)))))
```

A `(cost fanout)` pair — the `C_P` and `F_P` of Litwin & Risch 1992 §4.2.2,
the same two numbers `simple-pred-cost` returns and `dynprogsort` accumulates.

The tiers are coarse and deliberately so:

| Situation | cost / fanout | Meaning |
|---|---|---|
| no filter at all | 100000 | full collection scan — avoid |
| equality on an attribute | 10 | probably an indexed lookup |
| a range comparison | 100 | selective, but more work |
| some other extractable filter | 1000 | better than a scan |
| not executable | `nil` | this ordering is unsafe — reject it |

Returning `nil` for an unexecutable binding is the *safety* mechanism the 1992
paper describes in §5.2: a plan that calls a predicate in an unsupported
direction must be rejected, not merely priced badly.

### Finalizer — build the MongoDB query

`mongo-finalizer` converts the extracted predicates into an actual MongoDB
filter document. The operator mapping is declared at the top of the file:

```lisp
(defglobal _mongo-comparisons_
  (mapcar … '(< > <= >= != =) '("$lt" "$gt" "$lte" "$gte" "$ne" "$eq")))
```

So `x > 5` on attribute `"age"` becomes `{"age": {"$gt": 5}}`, and several
conditions are combined under `$and`. `generate-mongo-query` returns a pair —
the filter it built, and the predicates it could **not** absorb, which stay
behind as AMOS II post-filters.

It also handles the reversed form: `5 < x` is emitted as `{"age":{"$gt":5}}`
by consulting `inverse-comp`, since MongoDB filters always name the field
first.

When the filter contains variables not yet bound at plan time, the finalizer
emits a `substv` call to substitute them at run time before handing the record
to `mongo_query`.

## `index.osql` — an index *stored in* MongoDB

A separate idea from the wrapper: use a MongoDB collection as the backing
store for an AMOS II extensible index.

```sql
create function mongoIndex_make() -> Integer …
create function mongoIndex_put(Integer indx, Object k, Object v) -> Object
  as mongo_add(current_index_connection(), current_index_database(),
               mongoIndexName(indx), {"key":k, "val":v});
```

`_make` and `_put` are two of the five generic operations of **Mexima**,
AMOS II's extensible index manager — the same interface the KDTREE lab
implements in Java, discussed in
[`../query-rewrite/README.md`](../query-rewrite/README.md#corroboration-the-same-mechanism-working-in-the-mexima-lab).

The file looks **unfinished**: only `make` and `put` are present (no `get`,
`delete` or `clear`), and `set_index_database` has a typo — `Charsting`
instead of `Charstring` — which would fail to compile as written. Both
`set_index_database` and `mongoIndex_make` also place `set` statements *after*
their `return`, which is unlikely to be intended.

## Does this correspond to the 1992 paper?

**Partly — it is built on that foundation, but implements a later
architecture.** Worth separating the two.

### What comes straight from the paper

| Mechanism | Where it shows up here | Paper |
|---|---|---|
| Multi-directional foreign predicates | `'bf'`/`'fb'`/`'ff'` in the source predicate | §5.1 |
| Binding-pattern adornments | `mongo_query----+`, `mongo_queryBBBBF` | §2.3, §3.4 |
| `(cost, fanout)` estimates | `mongo-costmodel` returning `(list 10 10)` | §4.2.2 |
| Cost functions attached to foreign predicates | the registered cost model | §4.2.2 "cost hints" |
| Rejecting unexecutable binding patterns | `mongo-costmodel` returning `nil` | §5.2 "reordering for safety" |
| Generator/emit result protocol | `a_result(cxt)` per document | §5.1 footnote |
| ObjectLog predicate lists as the unit of work | everything in `mongo_optimizer.lsp` | §2.3 |

The cost model is the sharpest correspondence. `mongo-costmodel` returns
exactly the pair the paper defines, for exactly the purpose the paper defines
it — so the optimizer can compare a MongoDB access against alternatives using
one common currency.

### What is *not* in the paper

- **Wrappers and data sources.** `new_wrapper`, `Datasource`, `connect`,
  `set_extractor` / `set_finalizer` / `set_costmodel` — none of this exists in
  1992. The paper's foreign predicates are declared **per function**; a
  wrapper translates **per source**, over a whole conjunction at once.
- **Mediator features.** Mapped types, proxy objects, `create_mapped_type`,
  destructors — the machinery that makes a Mongo document behave like an AMOS
  II object. That is the mediator work described in
  `../../Amos-II-docs/FuncMedPaper.pdf`, not the 1992 paper.
- **Query *generation*.** The paper translates predicates into calls to
  foreign predicates. This generates a **query in another language**, assembled
  as a BSON document. `rewrite.txt` §1 names that as the translator's job —
  "query strings in the query language of the data source are generated as
  arguments of the interface functions" — and it is absent from 1992.

### Three mechanisms for one problem

Collecting what this repo has now seen, AMOS II has **three** ways to get a
conjunction of predicates evaluated by something other than itself:

| Mechanism | Granularity | Registered by | Weakness |
|---|---|---|---|
| **Capabilities** (built-in JDBC wrapper) | per source | declared capability functions | fails when a *combination* is unsupported — `rewrite.txt` §1 |
| **TBR-rewrite rules** | per predicate + binding pattern | `ADD-REWRITER` | `ranksort` only; fires on shape, no costing |
| **Extractor / finalizer** (this wrapper) | per source, whole conjunction | `set_extractor` etc. | must be written in Lisp per source |

The Mongo wrapper takes the third route, and in doing so sidesteps the exact
weakness `rewrite.txt` opens by criticising: the extractor decides what is
supported **per query** instead of declaring it once.

### One contrast worth noting

`rewrite.txt`'s `mbtree` example pushes `i>1 ∧ i<=4` into a B-tree range
call — and on the tested build that fails, because `MBT-SELECT-RANGE` has no
implementation bound ([see the investigation](../query-rewrite/README.md#why-mbtree-ranges-fail-on-this-build--resolved)).

This wrapper pushes the *same shape* of predicate — `$gt`, `$lte` — into
MongoDB, through a completely different path, with no such gap. Range
pushdown is not something AMOS II cannot do; it is something one particular
access routine on one build cannot do.

## Open: what a working build would settle

Blocked on compiling `MongoForeign.c` into `Mongo_wrapper.dll`. Recorded
here so the gap is explicit rather than implied, in three tiers by what each
one needs.

### Tier 0 — reachable now, with no compiler and no server

**Does the translator half load on its own?**

```lisp
(load_lisp "mongo_optimizer.lsp")
```

`mongo_optimizer.lsp` is pure Lisp and never calls `load_extension` itself,
so it may load even though every `.amosql` file in this directory cannot.
Success would confirm that the 2013–14 translator still parses on Release 16
v11 and that its helper functions — `leaf-predicate-p`, `variables-in-predl`,
`make-record1`, `getcalledpred` and the rest — still resolve. That is half
the wrapper verified with no toolchain at all.

It may equally fail on the first line. The file opens with

```lisp
(defglobal _record-vref_ (theresolvent 'record.charstring.vref->object))
```

and `theresolvent` runs at **load** time, so a missing function there aborts
immediately. Either outcome is informative, and it costs one command:

- **Loads** → the translator is intact; only the C interface is missing.
- **Fails on a `defglobal`** → shows exactly which system function has moved
  or been renamed in the intervening decade.
- **Fails elsewhere** → a genuine incompatibility worth recording.

*(Untested. This is the single cheapest probe available on this directory.)*

### Tier 1 — needs the DLL, no MongoDB server

- **Is there a `MongoWrapper.dmp` in the installed copy?** `readme.txt` step 5
  starts AMOS II from a saved image rather than loading the sources, which
  means the wrapper meta-data, the `new_wrapper("Mongo")` registration and
  the loaded `mongo_optimizer.lsp` may already be *inside* that image. If so,
  much of Tier 1 could be answered by `amos2 MongoWrapper.dmp` with no
  compiler — the DLL would only be needed once a foreign function is actually
  *called*. Untested, and it is unclear whether `load_extension` is replayed
  on image restore.
- **Is `installMongo.cmd` present?** `readme.txt` step 1 names it as the
  build script, but it is not in this directory. It is the missing piece for
  everything below.
- Does `load_extension("Mongo_wrapper")` resolve, and does `master.amosql`
  load cleanly on this release? The source is from 2013–14 and the build is
  Release 16 v11; a decade of drift could have broken something — the API
  churn visible between the two example files shows it was already moving
  fast in 2014.
- Do the three registrations take? `set_extractor` / `set_finalizer` /
  `set_costmodel` are undocumented in `rewrite.txt`, and probing what they
  store would document the wrapper API the way `ADD-REWRITER` returning an
  `#(TBR …)` struct documented the rewriter one.

### Tier 2 — needs the DLL *and* a MongoDB server

- The payoff: `pc()` on a query over an imported collection, showing a
  `mongo_query` call carrying a generated BSON filter. That would make the
  central claim of this page — that AMOS II pushes predicates into MongoDB —
  an observed fact rather than a code reading, exactly as `bar_range` did for
  the rewrite work.
- Whether `mongo-costmodel`'s tiers (10 / 100 / 1000 / 100000) actually steer
  the optimizer toward an equality access path over a collection scan.

## Related

- [`../query-rewrite/README.md`](../query-rewrite/README.md) — TBR-rewrite
  rules, the per-predicate alternative to this wrapper's extractor.
- [`../lisp-foreign-functions.md`](../lisp-foreign-functions.md) — the ALisp
  form of the foreign-function interface `MongoForeign.c` implements in C.
- [`../litwin-risch-1992-objectlog.md`](../litwin-risch-1992-objectlog.md) —
  the cost model, binding patterns and safety rules this wrapper inherits.
- [`../cost-based-vs-rule-based-optimization.md`](../cost-based-vs-rule-based-optimization.md)
  — predicate pushdown as Polars does it, for comparison.
