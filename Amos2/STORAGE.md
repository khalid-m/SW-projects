# The data model and storage

How Amos II stores objects, types and functions, how updates and indexes work, and how index
extensions (MEXIMA and the `extenders/`) plug in. Traced through [AmosNT_floq/lsp/](AmosNT_floq/lsp/),
[AmosNT_floq/system/C/mexima/](AmosNT_floq/system/C/mexima/) and
[AmosNT_floq/extenders/](AmosNT_floq/extenders/).

Companion to [QUERY_COMPILER.md](QUERY_COMPILER.md) (how queries over this data are compiled) and
[KERNEL.md](KERNEL.md) (the C side). The core object store, relations, hash index and core B-tree
are **binary-only** in this checkout ([KERNEL.md §2](KERNEL.md#2-what-has-source-and-what-doesnt)).
Where this file describes them, it relies on headers, symbol names and the Lisp code that calls
them. The Lisp layer, MEXIMA and the extenders all have source. Nothing here was run. Line numbers
refer to this checkout.

**Summary**

- **Everything is in main memory.** Objects, relations and indexes live in the Lisp heap or in C
  memory. Persistence means saving the whole heap as an image file (`save`), not writing to disk
  pages.
- **A stored function is a view over a hidden relation.** `create function f(T)->U as stored`
  creates a relation `p_f` and gives `f` the one-line body `p_f(args, results)`. Queries see `f`,
  and view expansion turns it into a relation access.
- **Updates go through the same function interface.** `set`/`add`/`remove` on a function either call
  a custom update function registered for it, or assert/retract rows in its relation.
- **Changes are logged for undo.** Functions whose names start with `/` record an undo event in the
  history log; plain ones don't.
- **Indexes are pluggable at two levels.** The core index table (`index.h`) has a built-in hash
  index. MEXIMA adds a second, generic interface with range scans, through which loadable extenders
  add `MBTREE`, `XTREE` and `JUDY` index types.

---

## 1. The layers

```
AmosQL      create type Person;  create function name(Person)->Charstring as stored;
            create Person(name) instances :p ("Ann");   set name(:p) = "Anna";
   │
Lisp        type = OID of type TYPE; function = OID of type FUNCTION with a selectbody
(lsp/)      stored function f  ──selectbody──►  (p_f  args… results…)
            relation p_f = OID of type RELATION, properties: width, indexes, predof = f
   │
C, binary   struct oidcell (amos.h:26): types, propl, next/prev in the type's extent
(system/)   struct indexcell (index.h:17): pos, unique, cardinality, rows, owner, type
            index_types[20] (index.h): hash (rel.obj), plus types registered at run time
   │
Extenders   MEXIMA (system/C/mexima/) → MBTREE (bt), XTREE (xt), JUDY (judy)
```

---

## 2. Objects and types

- **An object** is a C `struct oidcell` ([amos.h:26](AmosNT_floq/system/include/amos.h#L26)). It
  holds an id number, a list of types with the most specific first, a property list, and
  `next`/`prev` links that thread it into the extent of its most specific type. Lisp accesses these
  through macros in [basicoid.lsp](AmosNT_floq/lsp/basicoid.lsp) (`oid-idno` :64, `oid-types` :71,
  `oid-propl` :81).
- **A type is itself an object**, of type `TYPE`. The root types (`OBJECT`, `TYPE`, `FUNCTION`,
  `RELATION`, `CHARSTRING`, …) are created at boot (`create-root-types`, called from
  [coredef.lsp:267](AmosNT_floq/lsp/coredef.lsp#L267)). Their OIDs are kept in globals such as
  `_function_` and `_relation_` (coredef.lsp:126–178).
- **`create type T under S properties (…)`** expands (macro `create-type`,
  [proc.lsp:320](AmosNT_floq/lsp/proc.lsp#L320)) into `createusertype`, plus one `create-function`
  per property. **Properties are ordinary functions.** There is no separate attribute concept.
- **Extents.** `type-extent` ([basicoid.lsp:403](AmosNT_floq/lsp/basicoid.lsp#L403)) walks a type's
  extent with `mapextent`, i.e. the C linked list. It is not a stored table.
- **`create T(p1, p2) instances :x (v1, v2)`** expands (macro `create-userobjects`,
  [createuobj.lsp:24](AmosNT_floq/lsp/createuobj.lsp#L24)) into `/createobject` for the new object
  plus one `add-function` per property value (`compilefunsettings`, :85). New objects are populated
  through the ordinary update path in §4. A type can instead register a custom *constructor*
  (`constructor.lsp`); the relational wrapper uses this for writable imported tables.
- **Object properties.** Besides its functions, any OID has a Lisp property list used by the system
  itself: `getobject`/`putobject`, with transactional versions `/putprop`, `/addprop` and `/remprop`
  ([basicoid.lsp:324–338](AmosNT_floq/lsp/basicoid.lsp#L324)). This is where a function keeps its
  `selectbody`, `cost` and `bindings` ([QUERY_COMPILER.md §3](QUERY_COMPILER.md#3-the-central-data-structure-selectbody)).
- **Transient objects** (`create-transient-object`) are not part of the saved database: for example
  `_select_` and generated query functions.
- **Proxies** stand for objects in another Amos peer (`proxy-p`, `proxy-oid` and `proxy-database`,
  basicoid.lsp:429–444). They are used when types are imported from other peers
  ([typeimp.lsp](AmosNT_floq/lsp/typeimp.lsp)).

---

## 3. Stored functions and their relations

`createsimplestoredfunction` ([function.lsp:609](AmosNT_floq/lsp/function.lsp#L609)) is what
`create function … as stored` runs:

```lisp
(pfn (/createrelation (pack 'p_ (oid-name fno)) nil
                      (+ (length argl)(length resl))))      ; relation p_<name>, width = args+results
...
(/putobject pfn 'predof fno)                                 ; relation → its function
(setq pred (cons pfn pargl))                                 ; (p_f arg… res…)
...
(/putobject fno 'selectbody
            (make-selectbody :argl argl :resl resl ...
                             :pred pred :optpred pred :delpred pred))
```

- **The function is a view.** Its `pred`, its plan `optpred` and its update template `delpred` are
  all the single relation predicate `(p_f args… results…)`. When a query uses `f`, view expansion
  (`expand-predicate`) replaces it with the relation access, and the optimizer then chooses an index
  for it.
- **Default indexes** (`buildkeyindexes`, function.lsp:1098):
  - The **first argument** gets a hash index. It is **unique** if the function has exactly one
    argument, since `f(x)` then has at most one row per `x`.
  - A function with no arguments indexes its first result instead. That index is unique if there is
    a single result that isn't a bag.
  - `key` on an argument or result adds a unique index at that position. `nonkey` suppresses the
    default one.
- **Dependencies.** `addfunctionsusing` records both directions: the function uses the relation, and
  the relation is used by the function (properties `usesobjects` / `usedbyfunction`). Deletion
  (§6) and cost invalidation (`uncache-costs`) follow these links.
- **Finding the relation:** `get-relation` ([relation.lsp:233](AmosNT_floq/lsp/relation.lsp#L233))
  goes through `usedbyfunction` to the relation whose `predof` is `f`. `functiontype`
  (function.lsp:1179) reports `"stored"` when a relation exists.

### Relations and indexes (Lisp side)

[relation.lsp](AmosNT_floq/lsp/relation.lsp):

- A **relation** is an OID of type `RELATION` with properties `width` and `indexes`
  (`createrelation0`, :48). With no indexes specified, it gets one index on position 0 of type
  `_default-indextype_` = **`hash`** (:41).
- **`addindex0`** (:64) creates the index (`make-index`, which builds a C `indexcell`), fills it
  (`buildindex`, in binary `rel.obj`), and logs an undo event unless the change is permanent. It then
  does the one thing that connects storage to the optimizer:
  ```lisp
  (if (setq temp (getprop (index-type indx) 'index-rewriter))
      (add-rewriter ro (buildn (getobject ro 'width) '+) temp))
  ```
  If the index *type* has an `index-rewriter`, that rewriter is registered as a TBR rewriter on the
  relation (§7.4).
- **`createindex`** (:198) is the AmosQL-level `create index`. It finds the position through the
  function's `delpred`, adds the index, and clears cached costs (`uncache-costs`).
- **Index statistics used by the cost model.** The C `indexcell` ([index.h:17](AmosNT_floq/system/include/index.h#L17))
  keeps `cardinality` (number of distinct keys) and `totalrows`. `index-fanout` and `localcost` in
  `optimizer.lsp` read them ([QUERY_COMPILER.md §5](QUERY_COMPILER.md#5-cost-model)). An empty
  database therefore gets the default fanouts.

---

## 4. Updates

The parser turns `set` / `add` / `remove` into `set-function` / `add-function` / `rem-function`
forms ([GRAMMAR_MAP.md](GRAMMAR_MAP.md), `update_stmt`). These are macros in
[fncall.lsp:305–327](AmosNT_floq/lsp/fncall.lsp#L305):

```lisp
;;; (parse "set foo(x,y)=<a,b> from t1 a, t2 b where a>2 and foo(b);")
;;; (SET-FUNCTION FOO (X Y) (A B)
;;;               FOREACH ((T1 A) (T2 B))
;;;               WHERE (AND (> A 2) (FOO B)))
(defmacro set-function (fn argl &rest tail)
  (compile-syscall-where 'setfunction fn argl tail *enclfn* nil t))
```

- **With a `from`/`where` clause**, the update runs once per result row of a query
  (`update-where`, `compiled-update-where`). The query is compiled like any other.
- **`set f(k) = v` means delete, then add** (`setfunction` :1234, `setfunction-dynamic`). It removes
  every existing row for key `k`, then adds `(k, v)`. `add` and `remove` insert or delete a single
  row. For a bag result, they iterate over its elements.
- **Custom update functions come first.** If a function has a registered set, add or remove function
  (`get-setfunction` etc.; registered with `set_setfunction`, `set_addfunction` and `set_remfunction`,
  [updates.lsp](AmosNT_floq/lsp/updates.lsp)), that function is called instead. This is how derived
  functions and wrapped sources become updatable. For example, the relational wrapper generates
  `set_<column>` functions that issue SQL `UPDATE` ([BIGINTEGRATOR.md §4.1](BIGINTEGRATOR.md#41-importing-a-table-creates-a-source-predicate)).
- **Otherwise** the update calls `addfunction0` / `remfunction0`, which require `delpredfunction`
  (i.e. that the function *has* a `delpred`, so it is updatable). The row goes into the relation named
  by the `delpred`. `addfunction0fn` is in binary `fncall.obj`, and row assertion is in `rel.obj`
  (`assertrelationfn`, `retractrelationfn`).

### Transactions

- **The `/` naming convention.** Across `lsp/`, a function whose name starts with `/` is the
  *transactional* version: it records an undo event. The plain name does the same without logging.
  Examples: `/createrelation` vs `createrelation`, `/addindex` vs `addindex`, `/putprop`,
  `/createobject`, `/purgeobject`.
- **Undo events** are declared with `new-event`, which names the event and its undo function, e.g.
  `(new-event '/assertrelation 'undo-assertrelation nil)` and `(new-event '/addindex 'undo-addindex nil)`
  ([relation.lsp:34–38](AmosNT_floq/lsp/relation.lsp#L34)). They go into the history log in
  `hist.obj` (`history_addfn`).
- **Rollback** replays undo functions back to a savepoint (`history_rollbackfn`). `commit` makes the
  changes permanent (`commitfn`). The REPL takes a savepoint around every statement and rolls back a
  statement that fails ([KERNEL.md §4](KERNEL.md#4-the-repl-and-parse-dispatch)).

---

## 5. Persistence: the image

There is no separate on-disk database format in the core. **`save 'file.dmp'`** writes the whole
Lisp heap (compiled system, schema and data) to an image, and starting `amos2` with that image
restores it ([KERNEL.md §3](KERNEL.md#3-startup)). `bin/amos2.dmp` is an empty database plus the
compiled system.

Memory outside the Lisp heap needs hooks. MEXIMA index structures are allocated in C (§7), so
[mex-save-restore.lsp](AmosNT_floq/system/C/mexima/lsp/mex-save-restore.lsp) registers:

```lisp
(register-rollout-form '(save-mexi) 'first)   ; before saving the image
(register-init-form '(load-mexi))             ; when an image starts
```

- **`save-mexi`** copies each standalone MEXIMA index into a Lisp array of alternating keys and
  values (`build-extent-mexi`). Indexes that belong to a relation are only recorded; they are rebuilt
  from the relation's data afterwards (`mex-relation-save-restore.lsp`; its log says "use primary
  index (HASH) to save/restore transient indexes").
- **`load-mexi`** recreates each index (`restore-mexi`) and re-inserts the saved pairs
  (`restore-extent-mexi`).

---

## 6. Deletion

[deletion.lsp](AmosNT_floq/lsp/deletion.lsp): `delete-object`, `purge-function` and `purge-type`
(macros at :159, :149 and :154) go through `deleteobject1` (:46), which marks the object and
everything that depends on it through `usedbyfunction`. So deleting a type removes its functions,
and deleting a function removes its relation. `clear_usesobjects_at_delete` and
`clear_usedbyfunction_at_delete` repair the dependency links. Objects can have several types, and
`remove type T from :x` takes one away. It also removes `:x`'s rows from the relations of `T`'s
functions (macro `remove-type` → `removetype1` / `removefrompfn`,
[createuobj.lsp:107–146](AmosNT_floq/lsp/createuobj.lsp#L107)).

---

## 7. Index implementations

### 7.1 Core indexes (binary)

The core registry is `index_types[MAX_INDEX_TYPES=20]` of `struct index_properties` (creator,
mapper, getter, inserter, deleter, counter, dropper; [index.h:55](AmosNT_floq/system/include/index.h#L55)),
filled by `define_index_type`. Built in:

| Type | Where | Notes |
|---|---|---|
| `hash` | `rel.obj` (`hash_creator` … `hash_counter`) | The default for every stored function |
| B-tree | `btree.obj` (`btree_mapper`, `btree_getter`, …) | Core B-tree. Binary-only; how it is exposed as an index type can't be read here |

The core interface has **get** (exact key), **insert**, **delete**, **count** and **map all**. It has
**no range scan**. Range access comes from MEXIMA.

### 7.2 MEXIMA: the generic index interface

MEXIMA (Thanh Truong, 2011–13, [system/C/mexima/](AmosNT_floq/system/C/mexima/)) lets an index be
written as plain C over `void*` keys, including range scans, and registers it as a core index type.
It is on by default (`_mexima-enabled_ t`, [lispdef.lsp:55](AmosNT_floq/lsp/lispdef.lsp#L55)).

**What an index implementation supplies** (`struct mexi_index_props`,
[mexima.h](AmosNT_floq/system/C/mexima/mexima.h)):

```c
struct mexi_index_props {
  char name[10];  char suffix[10];
  mexi_create create;   mexi_put put;   mexi_get get;   mexi_delete remove;   mexi_drop drop;
  mexi_full_mapping  full_mapping;      /* iterate everything              */
  mexi_range_mapping range_mapping;     /* iterate lower..upper            */
  mexi_compute_key   computekey;
  mexi_compare       compare;           /* NULL → Amos's generic a_compare */
  mexi_getidentifier getidentifer;
};
```

**How it is registered.** An extender exports `a_initialize_extension`, which fills this struct and
calls `define_index` ([mexima.c](AmosNT_floq/system/C/mexima/mexima.c)). That function:

1. calls `register_index(name)`, which puts a **core** `index_properties` entry into `index_types`
   under that name, overwriting any entry with the same name, with every hook pointing at MEXIMA's
   dispatchers `mex_idm_creator/getter/inserter/deleter/counter/dropper/mapper`
   ([mex_relation.c](AmosNT_floq/system/C/mexima/mex_relation.c));
2. stores the extender's own struct in a metadata table (`add_medatable`).

A core index of a MEXIMA type holds a **`mexi`** object ([mexi.h](AmosNT_floq/system/C/mexima/mexi.h),
storage type `MEXITYPE`) in its `rows` field. The mexi holds a pointer to the extender's structure,
the index type and the owning relation. Every core call is forwarded, e.g.
`mex_idm_getter → mexima_getfn → props.get(idxp, key, compare)`.

**The Lisp API** (`register_mexima`): `mexima-make`, `mexima-get`, `mexima-put`, `mexima-delete`,
`mexima-map`, **`mexima-range-map`** and `mexima-drop`, plus housekeeping (`list-mexi-objects`,
`restore-mexi`, `mexi-owner`, `mexi-count`). `mexima-range-map` is how range access gets out of an
extender, since the core interface has none.

**Index types defined in Lisp or AmosQL.** [mex_foreign.c](AmosNT_floq/system/C/mexima/mex_foreign.c)
registers index types whose operations are foreign functions (`register-indextype1`, :301). The log
of `mex-save-restore.lsp` notes "allowed to extend indexing through Foreign function".

### 7.3 The extenders

| Index type | Source | Author, date | Notes |
|---|---|---|---|
| **`MBTREE`** | [extenders/BTREE/](AmosNT_floq/extenders/BTREE/): `bt.c` (741 lines), `BT_mexi_extender.c` | "Sobhan.B", 2011 | Main-memory B-tree. Nodes sized from 750 bytes (`HALF_SIZE`, bt.h:46). Range scan through `BTmap0`. Registers as `"MBTREE"` |
| **`XTREE`** | [extenders/XTREE/](AmosNT_floq/extenders/XTREE/): `xtree.c`, `xsearch.c`, `xpbuild.c`, `xt_mexi_extender.c` | — | Multidimensional X-tree. Used for similarity and k-nearest-neighbour search through [rewriter-knn.lsp](AmosNT_floq/system/C/mexima/lsp/rewriter-knn.lsp) |
| **`JUDY`** | [extenders/Judy/judy_mexi_extender.c](AmosNT_floq/extenders/Judy/judy_mexi_extender.c) | — | Judy arrays. Builds against the bundled Judy 1.0.5 in `wrappers/trie/SCSQ-trie/Judy-1.0.5/` |

The templates in [extenders/myAmosExtenders/](AmosNT_floq/extenders/myAmosExtenders/) and
[myLispExtenders/](AmosNT_floq/extenders/myLispExtenders/) show how to write a new extension.

**Loading.** Extenders are shared libraries (`bt.so`/`bt.dll`, `xt.so`/`xt.dll`) loaded at run time
with `load-extension`. `system/Unix/Makefile` builds `bt.so` and `xt.so` alongside the kernel. Load
order in the standard image:

1. [lispdef.lsp:57–63](AmosNT_floq/lsp/lispdef.lsp#L57): `mex-basic.lsp`, then
   **`(load-extension "bt" t)`**, then `mex-lisp-interfaces.lsp` (which defines `map-btree` over
   `mexima-range-map`) and `mex-transactional.lsp`.
2. [init.lsp:205–216](AmosNT_floq/lsp/init.lsp#L205): `mex-utilities.lsp`, `mex-amos-interfaces.lsp`
   and `mex-relation-save-restore.lsp`, then `(if (load-extension "xt" t) (load "mexima.lsp"))`.
   `mexima.lsp` sets up XTREE and the k-NN rewriter.

The `t` in `(load-extension "bt" t)` means that if `bt.so`/`bt.dll` can't be loaded, the system
starts anyway, **without the `MBTREE` index type**. XTREE is optional in the same way.

### 7.4 How a range index gets into a plan: `mbtree`

[mbindex.lsp](AmosNT_floq/lsp/mbindex.lsp) is a complete, short example of a TBR rewriter
([QUERY_COMPILER.md §6](QUERY_COMPILER.md#6-two-kinds-of-rewrite-rules)):

```lisp
(putprop 'mbtree 'index-rewriter 'rewrite-mbtindex)
```

Adding an `mbtree` index to a relation therefore registers `rewrite-mbtindex` on it (`addindex0`,
§3). During ranking (`rewrite-preds`), for a call to that relation, `rewrite-mbtindex`:

1. returns `substitute` (let the ordinary access path handle it) if nothing else remains, if the
   relation has no `mbtree` index, or if some **bound** position already has an index;
2. otherwise builds a `cc-comp` record per indexed variable, and scans the remaining predicates for
   `<`, `<=`, `>` or `>=` between that variable and a bound value. It flips `x < y` into
   `y > x` when needed and tightens `low`/`high` (`set-low-bound`, `set-high-bound`);
3. if some variable got a bound, emits
   `(call mbt-select-range <fn> <relation> <pos> <low> <high> <args…>)`, removes the inequalities it
   used, and adds `x != v` tests for strict bounds (the range itself is inclusive). It returns
   `success`.

`mbt-select-range` walks the B-tree with `map-btree` → `mexima-range-map`. Its cost hint is
`mbt-select-cost`: cost `max(1, 4·log₅₀₀(cardinality))`, fanout 4 (`init-mbtree`, called from
[amosdef.lsp:120](AmosNT_floq/lsp/amosdef.lsp#L120)).

**About your earlier investigation.** Your
[query-rewrite/README.md](../amos-query-optimization/query-rewrite/README.md) traced failing
`mbtree` range queries to `MBT-SELECT-RANGE` being declared but unbound. In this checkout
`init-mbtree` defines it as a foreign function implemented by the Lisp function `mbt-select-range`,
and `map-btree` is loaded unconditionally. The failure therefore comes from something this source
doesn't show: the build you tested was probably a different release, or its image was built
differently. The one condition visible here that disables `mbtree` altogether is `bt.so`/`bt.dll`
failing to load (§7.3). That would break creating the index, which is a different symptom.

---

## 8. Quick reference

| Question | Where |
|---|---|
| What does `create function … as stored` create? | `createsimplestoredfunction`, function.lsp:609 |
| Which indexes does a new stored function get? | `buildkeyindexes`, function.lsp:1098 |
| Where is a function's relation? | `get-relation`, relation.lsp:233; property `predof` |
| How does `set f(x)=v` run? | `set-function` → `setfunction`, fncall.lsp:305, :1234 |
| How do I make a derived or wrapped function updatable? | `set_setfunction` / `set_addfunction` / `set_remfunction`, updates.lsp |
| Is this call logged for undo? | Its name starts with `/` |
| Default index type? | `_default-indextype_` = `hash`, relation.lsp:41 |
| How does a new index type reach the optimizer? | `(putprop '<type> 'index-rewriter '<fn>)` + `addindex0`, relation.lsp:64 |
| How do I write a new index? | `struct mexi_index_props` + `a_initialize_extension` + `define_index`; see `extenders/BTREE/BT_mexi_extender.c` |
| What survives `save`? | The Lisp heap; MEXIMA indexes through `save-mexi` / `load-mexi` |
