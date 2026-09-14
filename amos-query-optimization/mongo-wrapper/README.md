# The AMOS II MongoDB wrapper

A complete, production-shaped **wrapper** that makes MongoDB collections
queryable from AmosQL — including pushing predicates down into MongoDB rather
than fetching everything and filtering locally.

Authored at UDBL, Uppsala: Khalid Mahmood (C interface, 2013) and Tore Risch
(query processor and optimizer extensions, 2014).

> **Status.** This page is a **reading of the source**, not a verified run.
> Exercising it needs a MongoDB server, the MongoDB C driver, and
> `MongoForeign.c` compiled against `amos2.lib` — none of which is set up
> here. Per [`../CLAUDE.md`](../CLAUDE.md)'s convention, treat the behavioural
> claims below as *what the code says it does*, not as observed output.

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

Two further files sit outside that stack:

| File | Role |
|---|---|
| `index.osql` | a Mexima-style extensible index whose storage is a MongoDB collection |
| `MongoWrapper.osql` | an earlier standalone meta-data file, superseded by `mongo_interface.amosql` |
| `master.amosql` | the loader — reads the interface then the query processor |
| `readme.txt` | generic build instructions for **any** AMOS II C extender; not MongoDB-specific |

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

## Related

- [`../query-rewrite/README.md`](../query-rewrite/README.md) — TBR-rewrite
  rules, the per-predicate alternative to this wrapper's extractor.
- [`../lisp-foreign-functions.md`](../lisp-foreign-functions.md) — the ALisp
  form of the foreign-function interface `MongoForeign.c` implements in C.
- [`../litwin-risch-1992-objectlog.md`](../litwin-risch-1992-objectlog.md) —
  the cost model, binding patterns and safety rules this wrapper inherits.
- [`../cost-based-vs-rule-based-optimization.md`](../cost-based-vs-rule-based-optimization.md)
  — predicate pushdown as Polars does it, for comparison.
