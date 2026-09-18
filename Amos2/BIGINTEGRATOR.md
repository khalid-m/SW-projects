# BigIntegrator, the relational wrapper, and FLOQ

How Amos II pushes parts of a query down to external databases, and how FLOQ used that machinery to
query many log databases together with one metadata database. Traced through
[AmosNT_floq/BigIntegrator/](AmosNT_floq/BigIntegrator/) and
[AmosNT_floq/wrappers/](AmosNT_floq/wrappers/).

Companion to [QUERY_COMPILER.md](QUERY_COMPILER.md): §4.7 there shows where the absorber and finalizer
sit inside the optimizer. This file covers what they do and the wrappers that plug into them. As
before, nothing was run: the relational side needs live MySQL and SQL Server databases, and FLOQ
needs specific 2013–14 servers (§6.7). Line numbers refer to this checkout.

**Summary**

- **BigIntegrator** (Minpeng Zhu and Tore Risch, 2012–13) is a small, generic framework. Each wrapper
  registers an *absorber*, which claims the parts of a query its source can run, and a *finalizer*,
  which turns the claimed part into a native query. It works on top of the ordinary cost-based
  optimizer.
- **The relational wrapper** is the complete, working example. Joins between tables in one database,
  comparisons and simple arithmetic collapse into one generated SQL query per database.
- **FLOQ** is research code, unfinished in this checkout. It asks one declarative query over a MySQL
  metadata database plus a *collection* of SQL Server log databases, which Amos peers query in
  parallel. The automatic, query-driven version lives in files that the standard image does not load.
  The experiment scripts load them by hand.

---

## 1. What is live and what isn't

The directories contain old copies, Emacs backups (`*.~N~`, `#…#`) and experiments. What
`init.lsp` actually loads into `amos2.dmp`:

| Loaded by | Files |
|---|---|
| `lsp/coredef.lsp:254` | `BigIntegrator/src/Lisp/`: [absorbmng.lsp](AmosNT_floq/BigIntegrator/src/Lisp/absorbmng.lsp), [misc.lsp](AmosNT_floq/BigIntegrator/src/Lisp/misc.lsp), [finalizermng.lsp](AmosNT_floq/BigIntegrator/src/Lisp/finalizermng.lsp) |
| `init.lsp` → [master.amosql](AmosNT_floq/BigIntegrator/src/AmosQL/master.amosql) | [integrator.lsp](AmosNT_floq/BigIntegrator/src/Lisp/integrator.lsp), [integrator.amosql](AmosNT_floq/BigIntegrator/src/AmosQL/integrator.amosql), [meta_data.amosql](AmosNT_floq/BigIntegrator/src/AmosQL/meta_data.amosql), [accessfilter.lsp](AmosNT_floq/BigIntegrator/src/Lisp/accessfilter.lsp), [wrapperfuncs.lsp](AmosNT_floq/BigIntegrator/src/Lisp/wrapperfuncs.lsp) |
| `init.lsp` → [wrappers/load_wrappers.lsp](AmosNT_floq/wrappers/load_wrappers.lsp) | `wrappers/datasource/*`, `wrappers/relational/` (via its [load_wrapper.lsp](AmosNT_floq/wrappers/relational/load_wrapper.lsp): `relational.lsp/.osql`, `sqlquery.lsp`, `import-table.lsp`, `sql.lsp`, `relational_translator.lsp`, …), then `configuration.osql`, **`sql_absorber.lsp`**, **`sql_finalizer.lsp`**, `numwrapper.lsp`, `patch.lsp`; `wrappers/JDBC/*` |

**Not loaded:**

| File(s) | What it is |
|---|---|
| [BigIntegrator/relational/](AmosNT_floq/BigIntegrator/relational/) | An older (2012) copy of `wrappers/relational/`. The live copy's log: "move the running SQL wrapper code to AmosNT/wrappers" (2012-10). |
| [wrappers/relational/sql_finalizer_new.lsp](AmosNT_floq/wrappers/relational/sql_finalizer_new.lsp) | **The FLOQ finalizer** (June 2014). Loaded only by the FLOQ experiment scripts (§6.4). |
| [wrappers/relational/sql_cost.lsp](AmosNT_floq/wrappers/relational/sql_cost.lsp) / `.osql` | A cost model that knows about primary keys. Commented out ([load_wrapper.lsp:25–26](AmosNT_floq/wrappers/relational/load_wrapper.lsp#L25)). |
| [wrappers/relational/capabilities.osql](AmosNT_floq/wrappers/relational/capabilities.osql), `lsp/translator.lsp` | The previous mediator API ("translator", Martin Hansson, 2000–02). `init.lsp:180` prints "disable translator.lsp", and both `capabilities.osql` loads are commented out. |
| `BigIntegrator/{Bigtable,SparQL,JDBC}/` | Wrappers for other kinds of source, built with their own scripts (`compileBT.cmd`, …). |

Some old-API code still runs: the relational finalizer builds its query function with
`create-specialized-query-fn` from `relational_translator.lsp`.

---

## 2. The model

```
 Datasource (type)
   └─ Relational (type)        ← a WRAPPER is a type; absorber/finalizer are stored on it
        └─ Jdbc (type)         ← subtypes inherit absorber/finalizer via supertypes
             ├─ :a     "metadb"   ← a DATA SOURCE is an instance (a connection)
             └─ :metas "metadb_s"

 SQL:SENSORINSTALLATION  ()->(SI, MI, SM, EV, TH, …)   ← SOURCE PREDICATE, one per imported table
      cclusterfct? = t        datasource(fn) = :a        absorbability(:a) ∋ this fn
```

| Concept | What it is | Defined in |
|---|---|---|
| **Wrapper** | A *type* under `Datasource`. `wrapper(ds)` is just `typeof(ds)`. | [integrator.amosql:35](AmosNT_floq/BigIntegrator/src/AmosQL/integrator.amosql#L35) |
| **Data source** | An instance of a wrapper type, e.g. one JDBC connection | — |
| **Source predicate** (older name: *core-cluster function*) | A function with no arguments that returns one table's columns. Marked `cclusterfct?`; `sourcepred?` checks it | [import-table.lsp:155](AmosNT_floq/wrappers/relational/import-table.lsp#L155), [absorbmng.lsp:54](AmosNT_floq/BigIntegrator/src/Lisp/absorbmng.lsp#L54) |
| **`datasource(Function sp)`** | Which data source(s) a source predicate belongs to. It can be a **set** (§6) | [integrator.amosql:31](AmosNT_floq/BigIntegrator/src/AmosQL/integrator.amosql#L31) |
| **Absorbability** | The *functions* a source can evaluate itself. Set per wrapper type and/or per data-source instance, inherited via supertypes (`get_absorbability`) | [integrator.amosql:23–29, 103–111](AmosNT_floq/BigIntegrator/src/AmosQL/integrator.amosql#L23) |
| **Absorber** | Lisp function `(sp predl) → absorberresult`: which predicates this source takes | registered by name with `set_absorber` |
| **Access filter** | What the absorber's claim becomes in the plan: `(access-filter <expression> vars…)`, where the `expression` holds the absorbed predicates, the source and the finalizer | [accessfilter.lsp:12](AmosNT_floq/BigIntegrator/src/Lisp/accessfilter.lsp#L12) |
| **Finalizer** | Lisp function that turns an access filter into a call to a native-query function, e.g. an SQL string | registered with `set_finalizer` |

Absorbability is matched by function **name**, not OID (`allowed-pred`,
[misc.lsp](AmosNT_floq/BigIntegrator/src/Lisp/misc.lsp)). For example, `'<'` covers every
resolvent of `<`.

### Registering a wrapper (AmosQL API)

The whole relational configuration fits in a few lines
([configuration.osql](AmosNT_floq/wrappers/relational/configuration.osql)):

```sql
set_absorber('relational', 'absorb-sql');     /* In sql_absorber.lsp */
set_finalizer('relational', 'finalize-sql');  /* In sql_finalizer.lsp */
create_wrapper_absorbability('relational', '<');   /* also <= > >= like = != */
create_wrapper_absorbability('relational', 'number.number.plus->number');
create_wrapper_absorbability('relational', 'number.number.times->number');
create_wrapper_absorbability('relational', 'VECTOR.IN->OBJECT');
create_wrapper_absorbability('relational', 'abs');
/* params: amos fn, sql operator, infix, hasvalue, reverse */
sqloperator("!=", "<>", true, false, false);
sqloperator('VECTOR.IN->OBJECT', 'in', true, false, true);
...
```

`sqloperator` is a separate, relational-only table that maps an Amos function to its SQL spelling.
Adding a pushable function means one absorbability line plus one `sqloperator` line. The file shows
this with `sin` (commented out).

---

## 3. Where it runs in the optimizer

From [QUERY_COMPILER.md §4.4–4.7](QUERY_COMPILER.md#44-optimization-entry-optimize-pred-and-decompose-pred),
inside `decompose-pred`:

```
TR predicate (views already expanded, so imported tables appear as source predicates)
  │  absorber-rewrite            absorbmng.lsp:33
  │    for each source predicate: call its wrapper's absorber
  │    → one (access-filter expr vars…) per claimed group; absorbed predicates removed
  ▼
  optimize-compound-predicate    ranksort etc.; access filters are costed by
  │                              accessfilter-cost---++ (§3.1) like any other predicate
  ▼
  finalize                       finalizermng.lsp:74
  │    finalize-tbr for each access filter: adjust-filter, then (funcall finalizer …)
  │    → wrapper returns TR predicates, e.g. (apply_pred <sql@ds:'select …'> in… out…)
  │    then the whole plan is converted back to TR and optimized AGAIN
  ▼
TBR plan
```

**Absorption repeats until nothing changes.** `absorb-predicates` (absorbmng.lsp:90) goes through the
conjunction. The first source predicate whose wrapper has an absorber gets to claim predicates, the
claim is replaced by an access filter, and the scan starts again, until no source predicate is left
unclaimed. Claimed predicates that are not source predicates, such as comparisons, are removed from
the conjunction at the end (`remove-absorbedpreds`).

**`adjust-filter`** ([finalizermng.lsp:178](AmosNT_floq/BigIntegrator/src/Lisp/finalizermng.lsp#L178))
runs just before each finalizer. It fixes up the absorber's choices now that the order of the plan,
and so which variables are bound, is known. Example: a join like `(> v1 v2)` between two sources may
have been absorbed by both, and must now be dropped from one. Its comment: "newer code compared to
cvs … can't pass regress yet".

### 3.1 How access filters are costed

`access-filter` is an abstract foreign function whose cost comes from a **cost hint** (the mechanism
in [QUERY_COMPILER.md §5](QUERY_COMPILER.md#5-cost-model)):

```lisp
(declarecosts _access-filter_ '*any* _accessfilter-cost_)   ; accessfilter.lsp
```

`accessfilter-cost---++` (:24) is a fixed set of heuristics. `size` is `collectionSize(dsn,
collection)` ([meta_data.amosql](AmosNT_floq/BigIntegrator/src/AmosQL/meta_data.amosql)) when known,
otherwise the default fanout 10000. The default cost is 100000.

| Absorbed content | Fanout | Cost |
|---|---|---|
| nothing, size known | size | 10000 + 100·size |
| contains an `=` | size / 200 | 10000 + 100·fanout |
| other comparisons | size / 10 | 10000 + 100·fanout |
| another source predicate (a join) | 100 × default | 10000 + 100·fanout |
| an OR or other compound | default | 10000 + 100·fanout |
| **a set of data sources** (§6) | *n* × 100 × default | 10000 + 100·fanout |

The comment `;;R=(F-1)/C` shows these numbers were meant to be fed into `ranksort`'s rank formula.

**After finalization, every relational query is costed at a constant.** `finalize-sql` declares
`sqlq_cost` on each generated query function, and `sqlq_cost` is `select 100,100`
([sql_finalizer.lsp:132](AmosNT_floq/wrappers/relational/sql_finalizer.lsp#L132)). So when
`finalize` re-optimizes the plan, every generated SQL query costs (100, 100) whatever it does. The
key-aware model in `sql_cost.lsp` would do better, but it is not loaded (§1).

---

## 4. The relational wrapper

### 4.1 Importing a table creates a source predicate

`import_table(ds, 'SENSORINSTALLATION')`
([relational.osql](AmosNT_floq/wrappers/relational/relational.osql)) creates a *mapped type*
`SensorInstallation@A` whose property functions (`si`, `ev`, `th`, …) are views over a source
predicate. The predicate itself is built by `create-relational-core-cluster-fn`
([import-table.lsp:155](AmosNT_floq/wrappers/relational/import-table.lsp#L155)):

- **Name** `SQL:<table>` (with `_sql-namespace_`, which is on). It takes no arguments, returns every
  column, and is `multidirectional`.
- **It can run without being absorbed.** Its all-free (`ff…f`) implementation is a Lisp closure that
  runs `select c1,…,cn from <table>` through `sql(ds, …)`. So a query still works, as a full scan,
  if the absorber claims nothing.
- `(addfunction 'absorbability (list ds) (list fno))` puts the predicate **into its own source's
  absorbability**. That is what lets one table's absorber claim another table from the same database.
- `(addfunction 'datasource (list fno) (list ds))` records where it lives.
- `declare-keys` registers the table's keys as **key groups**. The TR-level key unification
  (`inferequals`, [QUERY_COMPILER.md §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2)) therefore
  applies to wrapped tables too, and removes duplicate lookups before the absorber ever runs.

Because the property functions are derived, **view expansion** (`expand-predicate`) inlines them, so
by the time the absorber runs, `th(si) > 10` appears as `SQL:SENSORINSTALLATION(…, th, …)` plus
`(> th 10)`.

Updatable imports also get generated `set_`/`add_`/`remove_` functions that issue `UPDATE`/`INSERT`/
`DELETE` through `sqlu` (`create-keyed-set-fn`, import-table.lsp:246).

### 4.2 The absorber: `absorb-sql`

[sql_absorber.lsp:18](AmosNT_floq/wrappers/relational/sql_absorber.lsp#L18). It starts from one
source predicate `sp` and grows the claimed set until nothing changes. A leaf predicate `p` is
claimed when (`leafpred-absorbablep`, :108):

1. **the source can run it**: its function name is in `get_absorbability(ds)`, *or* it is a source
   predicate of the **same** data source; **and**
2. **it shares a variable** with something already claimed (`joins-with`).

A compound predicate (an OR) is claimed only if every leaf in it qualifies (`all-absorbablep`). When
another table is claimed, its variables join the access filter's variable list.

What this means for a query:
- **Same-database joins** become one SQL join.
- **Filters on columns** (`th > 10`), `like`, `in`, `abs`, and `+`/`*` expressions go into the
  `WHERE` clause.
- A predicate that shares no variable with a table stays in Amos.
- **Tables in different databases never merge.** Each gets its own access filter, and the join between
  them is left to the Amos optimizer.

Two flags change the arithmetic handling. `*numwrapper*` (default `t`) allows arithmetic to be pushed
down. When it is off, predicates that depend on variables bound by arithmetic are dropped from the
claim (`numpredbindsvar`).

### 4.3 The finalizer: `finalize-sql`

[sql_finalizer.lsp:29](AmosNT_floq/wrappers/relational/sql_finalizer.lsp#L29). It:

1. Builds a `sqlquery` struct ([wrapperfuncs.lsp](AmosNT_floq/BigIntegrator/src/Lisp/wrapperfuncs.lsp))
   and distributes the claimed predicates into it (`sqlquery-add-predicate`,
   [sqlquery.lsp:136](AmosNT_floq/wrappers/relational/sqlquery.lsp#L136)). Source predicates become
   tables, comparisons go to the `WHERE` part, and arithmetic that produces an output becomes a select
   item.
2. Translates each source predicate (`relational-translate-source-predicate`,
   [relational_translator.lsp:83](AmosNT_floq/wrappers/relational/relational_translator.lsp#L83)).
   A **bound** column becomes `col = ?`, an input parameter. A **free** column becomes an output.
   A constant becomes `col = <literal>`.
3. Generates the SQL (`generate-sql-string`, [sqlquery.lsp:447](AmosNT_floq/wrappers/relational/sqlquery.lsp#L447)):
   `select <outputs or 1> from <tables with aliases> where <predicates>`.
4. Wraps it in a transient function with body `(sql ds "<SQL>" (vector inputs…))` and the name
   `sql@<ds>:'<SQL>'(inputs)->(outputs)`. That name is what appears in `pc()` output. It gets the
   constant cost `sqlq_cost`.
5. Returns `((apply_pred <that function> inputs… outputs…))` to the finalizer manager, which puts it
   into the plan and re-optimizes.

Because bound columns become `?` parameters, the generated query **runs once per binding** of its
inputs. If Amos binds a column before the SQL call, the call acts as a bind join (one parameterized
query per outer row).

**Table aliases** (`make-table-aliases`, [sqlquery.lsp:197](AmosNT_floq/wrappers/relational/sqlquery.lsp#L197)).
Each table gets `<shortest unique prefix>_`. A column is qualified only when its name is ambiguous
across the tables (`column-ambiguous?`). There is a small bug. When one table name is a prefix of
another, `shortest-unique-prefix` (:184) runs past the end of the shorter name and appends `NIL`.
`MACHINE` next to `MACHINEINSTALLATION` becomes **`MACHINENIL_`**.

### 4.4 Example: a real generated query

`bij.osql` contains this SQL. It is almost certainly copied from generated output: the aliases
`L_`, `S_`, `MACHINENIL_` and `MACHINEI_`, and the choice of which columns to qualify, match the
algorithm above exactly. It is the metadata part of the FLOQ query (§6.3):

```sql
select LID,URI,SI,S_.MI,EV,TH,MACHINENIL_.M
from LOCATION L_,SENSORINSTALLATION S_,MACHINE MACHINENIL_,MACHINEINSTALLATION MACHINEI_
where MACHINEI_.MI = S_.MI AND MACHINEI_.M = MACHINENIL_.M AND LOCATEDAT = LID
```

- **Four tables in one database became one query.** Each is a source predicate of `:metas`; the
  absorber joined them through the shared variables `mi`, `m` and `lid`.
- **Unqualified columns are unambiguous.** `LID`, `URI`, `SI`, `EV`, `TH` and `LOCATEDAT` each exist
  in only one table. `MI` and `M` exist in two, so they are qualified.
- **The join conditions came from unification, not from `=` predicates in the query.** The AmosQL
  equalities `mi(mi)=mi(si)`, `m(mi)=m(m)` and `lid(l)=locatedat(mi)` were unified into shared
  variables. The SQL generator then wrote a shared variable as `col = col`.
- **The measurement comparison (`mv > ev + th`) is not here.** It involves `MeasuresA`, a different
  source, so it was left for Amos or for FLOQ to join (§6).

---

## 5. Other wrappers in this framework

- [wrappers/JDBC/](AmosNT_floq/wrappers/JDBC/): a `Jdbc` subtype of `Relational` with Java-backed
  `sql(Jdbc ds, …)`. It inherits the relational absorber and finalizer through the supertype lookup
  (`get_superty_absorber`), which is why FLOQ's MySQL and SQL Server connections need no
  configuration of their own.
- [BigIntegrator/Bigtable/](AmosNT_floq/BigIntegrator/Bigtable/) (Google App Engine datastore, Java +
  `gqlquery` struct) and [BigIntegrator/SparQL/](AmosNT_floq/BigIntegrator/SparQL/)
  (`sparql-query` struct) are the non-SQL wrappers. The per-language query structs sit side by side
  in `wrapperfuncs.lsp`.

---

## 6. FLOQ

The name is not expanded anywhere in the tree. Every FLOQ file is by Minpeng Zhu (UDBL, 2012–14).

### 6.1 The scenario

Industrial equipment at several sites. **One metadata database** (MySQL,
[metadb.sql](AmosNT_floq/BigIntegrator/regress/metadb.sql)):

```
Machine(m, mmname, …)           Sensor(sm, sname, maxv, minv, …)
Location(lid, name, country, …, uri)   ← uri = JDBC URI of that site's LOG database
MachineInstallation(mi, m → Machine, locatedat → Location)
SensorInstallation(si, mi → MachineInstallation, sm → Sensor, ev, th, …)
```

It comes in three sizes: `metadb_s` (100 machine installations, 200 sensors), `_m` (200/400) and
`_l` (500/1000) ([FLOQ/readme.txt](AmosNT_floq/BigIntegrator/FLOQ/readme.txt)).

**Many log databases** (SQL Server) hold the measurements: `measuresA(m, s, bt, et, mv)`. The
experiments used two servers (`udblserver1`, `udblserver3`) with log databases `bm1GB`, `bm5GB`,
`bm10GB` and `bm15GB`.

**The question is "What equipment has failed?"**: which measurements exceed their sensor's expected
value plus its threshold (`mv > ev + th`), where `ev`/`th` come from the metadata and each sensor's
readings live in whichever log database its location's `uri` names.

### 6.2 Modelling the log databases as one source

`import_table2` ([regress/patch.osql](AmosNT_floq/BigIntegrator/regress/patch.osql)) imports
`MEASURESA` **once**, for the whole collection:

```sql
import_table2(first(:js), 'MEASURESA', :js);   /* :js = the set of log-db connections */
```

- It **adds a column `jdbcURI`** to the source predicate (`import-table2`: "i want to add an extra
  attribute uri in measuresA"). Each measurement therefore carries the log database it came from.
- It records the source predicate's `datasource` as **the whole set** `js` rather than one connection.

Everything downstream checks for this with `(consp dsinst)`:
- the absorber takes its capabilities from the first member;
- the access filter's cost is multiplied by the number of sources (§3.1);
- the finalizer produces a *multi-database* query instead of a single `sql@ds` call.

### 6.3 The query

From [regress/multisql.osql](AmosNT_floq/BigIntegrator/regress/multisql.osql), for the small
metadata database:

```sql
create function newq4s()->(Integer, Number, Number) as
select m(ma), bt(ma), et(ma)
from SensorInstallation@metas si, Location@metas l, MeasuresA ma,
     MachineInstallation@metas mi, Machine@metas m
where mv(ma) > ev(si) + th(si) and
      lid(l)=locatedat(mi) and mi(mi)=mi(si) and m(mi)=m(m) and
      s(ma)=si(si) and m(ma)=mi(si) and
      uri(l)=jdbcuri(ma);          /* route each sensor to its own log database */
```

This is an ordinary declarative query. The goal of FLOQ is that the optimizer and wrappers turn it
into:
1. one metadata SQL query (the one in §4.4);
2. per log database, one parameterized query:
   `select bt,et,mv from measuresA where (mv-?)>? and m=? and s=?`;
3. run on all log databases **in parallel**.

### 6.4 How it is wired: loaded at run time, not in the image

The FLOQ pipeline is **not** in `amos2.dmp`. The experiment scripts do `< 'patch.osql'`, which:

- sets `_save-intermediates_ t` and `*use-dnf* nil`;
- redefines `import-table2` / `create-relational-sp-fn`;
- loads [sql_finalizer_new.lsp](AmosNT_floq/wrappers/relational/sql_finalizer_new.lsp) and
  [regress/fedquery.lsp](AmosNT_floq/BigIntegrator/regress/fedquery.lsp) (patch.osql:168–171).

`sql_finalizer_new.lsp` replaces `finalize-sql` with a version that takes **4 arguments** (`dsinst
preds sb bnd`). This matches the 4-argument call in the loaded `finalizermng.lsp:108`
(`(funcall finalizer ds (car adjustedfilter) sb bnd)`). The `finalize-sql` that *is* in the image
(`sql_finalizer.lsp:29`) takes 3.

So, in this checkout, **the finalizer manager expects the FLOQ finalizer**. Whether the plain
relational path works without `patch.osql` (i.e. whether aLisp tolerates the extra argument, or the
image was built with the new file) can only be settled by running it. The dates are suggestive:
`finalizermng.lsp` and `bin/amos2.dmp` are both from 2014-06-26, and `sql_finalizer_new.lsp` from
2014-06-11.

`sql_finalizer_new.lsp` also contains a lot of backup code in `(quote …)` blocks. Of its four
`create-specialized-query-fn2` definitions, only the first (line 108) is live.

### 6.5 Three execution strategies

The new `finalize-sql` (:247) picks one with `*enable-parallel*` (default `nil`). The third strategy
was scripted by hand.

**Sequential** (`*enable-parallel*` nil). The log-collection access filter becomes one function
named `multi_sql_union:'<SQL>'…`. Its body is `(multi_sql_union <logdb-uri-var> "<SQL>" (vector
inputs…))`. `multi_sql_union` (multisql.osql) looks up the JDBC connection for that URI
(`logdburi_js`) and runs the query there, so each metadata row triggers one query against its own log
database, one after another.

**Parallel bind join** (`*enable-parallel*` t). Two finalizer calls cooperate through **global
state**:

1. The **metadata** access filter is finalized first, by `create-specialized-query-fn3` (:199). It
   runs the metadata SQL into a materialized bag, appends that bag's variable to `*bvars*`, and saves
   its output variables in the global `*metadbcalloutputvarlist*`.
2. The **log-collection** access filter is finalized next, by `create-specialized-query-fn2` (:108).
   It takes the metadata bag as `(car (last bnd))` and emits a plan fragment directly:
   ```
   makebag   rows of the metadata bag → (logdb-uri, query-argument-vector) pairs
   makebag   groupby uri, vectorof           → one batch of argument vectors per log db
   formargfrombag                            → {peer-vector, batch-vector}
   apply_pred  multicastreceive3(peers, "sql_myv2", "<parameterized SQL>", batches, positions)
   ```
   Each peer runs `sql_myv2` ([regress/peer.osql](AmosNT_floq/BigIntegrator/regress/peer.osql)): for
   every argument vector in its batch, it runs the parameterized query against its local log
   database and returns `concat(arg, result)`. The metadata columns therefore come back alongside the
   measurements.

   `multicastreceive3` maps URIs to peer names (`mappinguri_peer`) and calls the built-in
   `multicastReceive(peers, fn, args)` ([lsp/multicast.lsp:34](AmosNT_floq/lsp/multicast.lsp#L34)).
   One comment gives the motivation: multicast is "4 times faster than call sql to every datasource
   in sequence … in a 4 processors machine".

   This strategy is correct only if the metadata filter is finalized before the log filter, because
   the log filter reads the global that the metadata filter sets. That coupling is a sign that the
   code was still in progress.

**Bulk-load and join remotely** ([regress/bij.osql](AmosNT_floq/BigIntegrator/regress/bij.osql),
written by hand, not generated). Write the metadata bindings for each server to CSV
(`writecsvfile`), `BULK INSERT` them into a `metabindings` table inside each log database, then have
each peer run the whole join locally:

```sql
select * from measuresA ma, metabindings mbs
where ma.mv > mbs.th + mbs.ev and ma.m = mbs.m and ma.s = mbs.s
```

### 6.6 The experiments

| Script | What it does |
|---|---|
| [multisql.osql](AmosNT_floq/BigIntegrator/regress/multisql.osql) | Main setup: connections, imports, peers, and queries `newq4`/`newq4s`/`newq4m`/`newq4l` (toy/s/m/l metadata) and `newq3` ("in Uppsala"), each with `pc(…)` then `count(…)` |
| [bjexp.osql](AmosNT_floq/BigIntegrator/regress/bjexp.osql) | "FLOQ bind join experiment set up" |
| [seqexp.osql](AmosNT_floq/BigIntegrator/regress/seqexp.osql) | "FLOQ runs in sequence experiment set up" |
| [bij.osql](AmosNT_floq/BigIntegrator/regress/bij.osql) | Bulk-load strategy over log dbs 1/5/10/15 GB × metadata s/m/l |
| [toyexp.osql](AmosNT_floq/BigIntegrator/regress/toyexp.osql) | "just for testing my query rewrite" |
| [testfloq.osql](AmosNT_floq/BigIntegrator/regress/testfloq.osql) + [floqtest.cmd](AmosNT_floq/BigIntegrator/regress/floqtest.cmd) | An earlier, smaller federation: 4 Amos peers (`u`, `e`, `g`, `v` = Uppsala, Enköping, Gävle, Västerås) with `srcschema.osql`, a client with `fedschema.osql` that uses `call_function`/`multicastreceive`. Includes a hand-written *multidirectional* `measure2` with separate `bbf`/`fbf` bodies. The notes say "works" / "doesn't work" and the file ends mid-sentence |
| [popmetadb.amosql](AmosNT_floq/BigIntegrator/regress/popmetadb.amosql) | Create and populate the MySQL metadata database through JDBC |

`BigIntegrator/FLOQ/` holds older copies (March–May 2014) of `bij.osql`, `bjexp.osql`, `peer.osql` and
`popmetadb.amosql`. The ones in `regress/` are newer (June 2014) and are the ones described above.
`sard/SARD2/experiments/floq/` holds a further copy.

### 6.7 Could it be re-run?

Not as written. The scripts hard-code:
- `udblserver1.it.uu.se` and `udblserver3` (SQL Server, user `udbl`);
- a Windows share `//130.238.14.85/Users/Public/FLOQ/`;
- a local MySQL with user `regress`;
- `javaamos` peers started with Windows `start`.

The log-database contents (`measuresA` at 1–15 GB) are not in the checkout. Re-running would mean:
build a runnable Amos (the Wine or 32-bit Linux route), stand up MySQL plus a few SQL Server or other
JDBC databases with generated `measuresA` data, and change the URIs.

---

## 7. Loose ends found in the code

| Where | What |
|---|---|
| `finalizermng.lsp:108` vs `sql_finalizer.lsp:29` | Finalizer called with 4 arguments; the loaded relational finalizer takes 3 (§6.4) |
| `sql_finalizer.lsp:132` | Every generated SQL query costed at a constant (100, 100) |
| `load_wrapper.lsp:25–26` | Key-aware `sql_cost.lsp` disabled |
| `finalizermng.lsp:178` | `adjust-filter`: "can't pass regress yet" |
| `sqlquery.lsp:184` | `shortest-unique-prefix` appends `NIL` (`MACHINENIL_`) |
| `sql_finalizer_new.lsp` | FLOQ parallel mode relies on finalization order and a global (`*metadbcalloutputvarlist*`) |
| `lsp/translator.lsp` | `create-core-cluster-function` ([wrappers/datasource/core-cluster.lsp](AmosNT_floq/wrappers/datasource/core-cluster.lsp)) registers the TBR rewriter `rewrite-extent`, which is defined only in the disabled `translator.lsp`. The relational wrapper uses its own constructor, so it is unaffected |
| `BigIntegrator/src/Lisp/`, `wrappers/relational/`, `regress/` | Emacs backups (`*.~N~`) and an autosave `#finalizermng.lsp#`, possibly with newer unsaved edits |

---

## 8. Relation to your Mongo wrapper notes

Your [query-translation.md](../amos-query-optimization/mongo-wrapper/query-translation.md) describes a
later Amos II release in which a wrapper registers `set_extractor`, `set_finalizer` and
`set_costmodel`. This checkout is the 2013 ancestor of that design:

| Your notes (later release) | This checkout |
|---|---|
| `set_extractor(wrapper, fn)` | `set_absorber(wrapper, fn)`: same role, claim the predicates a source can run |
| `set_finalizer(wrapper, fn)` | `set_finalizer(wrapper, fn)`: same name and role |
| `set_costmodel(wrapper, fn)` | Not present. Costs come from the generic `accessfilter-cost` heuristics (§3.1) and `declarecosts` hints (`sqlq_cost`) |
| extractor output → BSON filter | absorber output → access filter → `sqlquery` struct → SQL string |
| `mongo_query_processor.amosql` | [wrappers/Mongo/](AmosNT_floq/wrappers/Mongo/) here is the older, C-only generation: no absorber, not in the optimizer |

That *extractor* is a renamed *absorber* is an inference from the matching roles and signatures. The
relational wrapper in this file is a complete, readable example of the pattern your Mongo notes
describe: one absorber, one finalizer, and the ordinary optimizer between them.
