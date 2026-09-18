# The C kernel (`system/`)

How Amos II starts, reads a statement, hands it to Lisp, and runs the resulting plan. Traced through
[AmosNT_floq/system/](AmosNT_floq/system/) and the public headers in [AmosNT_floq/C/](AmosNT_floq/C/).
Companion to [QUERY_COMPILER.md](QUERY_COMPILER.md), which covers what happens in Lisp between parsing
and execution.

Line numbers refer to this checkout. **Part of the kernel has no source here** (§2). Statements about
those parts come from headers, symbol tables and call sites, and are marked *inferred*.

> Tip: `parser.y` and several other C files are ISO-8859 with CRLF line endings, so a plain `grep`
> treats them as binary and silently finds nothing. Use `grep -a`.

---

## 1. Three layers

```
┌──────────────────────────────────────────────────────────────────────────┐
│ lsp/*.lsp  query compiler, optimizer, DDL/DML semantics  (see QUERY_COMPILER.md) │
│            loaded once and saved in the image bin/amos2.dmp                │
├──────────────────────────────────────────────────────────────────────────┤
│ system/C/  Amos-specific kernel, SOURCE AVAILABLE                          │
│            startup, REPL, AmosQL + SQL parsers, C↔Lisp glue, client API,   │
│            sockets, coroutines, scans, extra datatypes                     │
├──────────────────────────────────────────────────────────────────────────┤
│ aLisp engine + storage, BINARY ONLY                                        │
│            evaluator, object store, reader/printer, OIDs, relations,       │
│            hash & B-tree indexes, history/transactions, ObjectLog executor │
└──────────────────────────────────────────────────────────────────────────┘
```

**Everything is an `oidtype`.** `typedef size_t oidtype;` is a handle into a tagged object store
([C/storage.h:118](AmosNT_floq/C/storage.h#L118)). Each object begins with
`objtags { objtype ttag; objrefcnt rcnt; }`: a one-byte type tag and a one-byte reference count.
Built-in tags include `LISTTYPE` 0, `SYMBOLTYPE` 1, `INTEGERTYPE` 2, `EXTFNTYPE` 4, `CLOSURETYPE` 5,
`STRINGTYPE` 6, `SURROGATETYPE` 13 (a database object) and `INDEXTYPE` 16
([storage.h:98–114](AmosNT_floq/C/storage.h#L98)). New tags are allocated at run time with
`a_definetype` (§6). The parsers do not build an AST of their own. They build Lisp lists out of these
objects.

---

## 2. What has source and what doesn't

The core modules have **no `.c` file** in this checkout. They exist only as compiled objects, in
[system/MVC/](AmosNT_floq/system/MVC/) (`*.obj`, Windows COFF, **symbol tables intact**) and
[system/Unix/Linux32/](AmosNT_floq/system/Unix/Linux32/) (`*.o`, ELF, stripped). `system/Unix/Makefile`
links `libamos.so` straight from `$(ARCHITECTURE)/*.o`.

Function counts come from `nm system/MVC/<module>.obj` (defined text symbols):

| Module | Fns | What it is (from its exported names) |
|---|---|---|
| `eval` | 98 | aLisp evaluator: `evalfn`, `evallist`, catch/throw, interrupts, backtraces |
| `systemfns` | 55 | Special forms: `defunfn`, `defmacrofn`, `condfn`, `andfn`, … |
| `extfns` | 135 | Built-in Lisp library: lists, arrays, properties |
| `read`, `print` | 16, 18 | Lisp reader (`a_read_from_string`) and printer |
| `storage` | 110 | Object memory, `a_definetype`, streams, errors, hooks |
| `oid` | 55 | Database objects: `createobjectfn`, `create_transient_objectfn`, supertypes |
| `rel` | 30 | Stored relations: `maprelation`, `assertrelationfn`, `getbestindexfn`, and the default **hash index** (`hash_creator` … `hash_counter`) |
| `index` | 25 | Index registry: `define_index_type`, `index_cardinalityfn` |
| `btree` | 34 | B-tree index implementation (`btree_mapper`, `btree_getter`, …) |
| `hist` | 12 | Update log and transactions: `history_addfn`, `history_rollbackfn`, `commitfn` |
| `fncall` | 14 | `callfunction`, `addfunction0fn`: calling an Amos function by OID |
| **`olog`** | 58 | **The plan executor** (below) |
| `misc` | 8 | Optimizer helpers in C: `coversfn`, `argsbpatfn`, `pred_bindsfn`, `osql_constantpfn` |

So even `optimizer.lsp` depends on binary code. `covers-dyn` calls `covers`, and `rewrite-preds`
calls `pred_binds`. Both are implemented in `misc.obj`.

**The executor, `olog.obj`** (all names *inferred*, since there is no source). Plan-running entry
points: `a_mapfunction`, `a_mapfunctionC` (declared in [C/callout.h:123](AmosNT_floq/C/callout.h#L123)),
`mapfunctionfn`, `mapfunction_applyfn`, `a_mapbag`, `a_mapstream`, `a_mapfunction_dist`. Evaluation
internals: `evalpred`, **`evalnlj` / `evalnljcont`**, `evaloptional` / `evaloptionalcont`,
`evalunionall`, `evalCfpcall` / `evalLispfpcall`, `access_relation`, `bindargs`, `bind_continue`,
`a_emit`, `delay_emitfn`, plus debugging (`trace_ologfn`, `olog_profilerfn`, `ologbtfn`). Read
against the plan format in [QUERY_COMPILER.md](QUERY_COMPILER.md#3-the-central-data-structure-selectbody),
this suggests the following. The TBR predicate is interpreted as nested-loop joins in continuation
style. `AND` runs left to right, binding variables as it goes. `OR` runs as a union of its branches.
`OPTIONAL` gets its own evaluator. Each `(call impl fn args…)` dispatches to a C function or a Lisp
function, and stored functions go through `access_relation` to `maprelation`.

Because these objects are 32-bit (`-m32`) builds from 2013, **there is no working build of this
checkout on a current Mac**. Everything below was read, not run.

---

## 3. Startup

[C/main.c](AmosNT_floq/C/main.c) is the whole program:

```c
int main(int argc,char **argv)
{
  init_amos(argc,argv);
  amos_toploop(""); /* Default prompter */
  return 0;
}
```

[C/alisp.c](AmosNT_floq/C/alisp.c) builds `bin/alisp` from the same kernel with a plain Lisp loop
(`evalloop`).

- **`init_amos`** ([system/C/init.c:1017](AmosNT_floq/system/C/init.c#L1017)): calls
  `init_subsystems` (:541), which runs every `register_*` function. Then it calls `process_options`.
- **`init_subsystems`** registers all the C built-ins. At :682 it installs
  `a_register_hook(exec_commands, AFTER_INIT)`, so command-line work runs as soon as the REPL starts.
  MEXIMA is registered only if the Lisp flag `_mexima-enabled_` is set (:686). It is set: see
  QUERY_COMPILER.md §4.3.
- **`process_options`** (:859): with no arguments it loads the default image
  (`init_from_image(a_default_image, …)`). Otherwise each flag is queued as a command
  (:950–992):

  | Flag | Queued as |
  |---|---|
  | `-O file.osql` | Lisp `(load-amosql "file.osql")` |
  | `-L file.lsp` | Lisp `(load "file.lsp")` |
  | `-o "stmt;"` | AmosQL statement |
  | `-l "(form)"` | Lisp forms |
  | `-q SQL` | sets `a_query_language`, the REPL's starting parser |

- **`exec_commands`** ([system/C/commands.c:78](AmosNT_floq/system/C/commands.c#L78)) first
  evaluates any `connect-forms`, then runs the queued commands in order: Lisp via `eval_forms`,
  AmosQL via `amosql()`. It finishes with **`commitfn(env)`**, so a `-O` load is committed as one
  unit if it succeeds.

The image (`bin/amos2.dmp`) holds the entire booted Lisp heap: all of `lsp/`, compiled and loaded,
plus the database. `system/Unix/Makefile` builds it with
`amos2 -i../../lsp/init.lsp -o "save '…/amos2.dmp';quit;"`.

---

## 4. The REPL and parse dispatch

### `amos_toploop` ([top.c:360](AmosNT_floq/system/C/top.c#L360))

Each iteration does the following:

1. Runs the init hooks once (`check_init_hooks`, which fires `exec_commands`).
2. Records `_history_` and `_generations_`.
3. Prints a prompt with the next savepoint number, e.g. `Amos 3>`.
4. Calls `parse_and_eval`.
5. Handles the outcome:
   - **on error**: `history_rollbackfn` undoes the failed statement (:393);
   - **on success**: `add_savepoint` records a new generation if anything changed (:394).

Every top-level statement is therefore its own undoable step. The loop also prints evaluation time
when it is nonzero, and sets `_regression-failed_` on an error during regression runs (:390).

### `parse_and_eval` ([top.c:281](AmosNT_floq/system/C/top.c#L281))

```c
res = (*(parsers[fs->language].parser))(env, fs);          /* Parse stmt      :303 */
lid = get_parser_id(res);                                  /* language switch? :305 */
...
if(fs->language==LISP){a_setf(globval(_within_lisp_),t)}   /*                :326 */
else {a_setf(globval(_within_lisp_),nil)};
...
a_let(res,evalfn(env, parsed_form));                       /* C → Lisp       :332 */
...
(*(parsers[fs->language].result_printer))(res);            /* print          :337 */
```

- **Line 332 is where C hands over to Lisp.** Everything in QUERY_COMPILER.md runs inside this
  `evalfn` call.
- **`*within-lisp*` connects the two sides.** Setting it to `nil` in AmosQL mode is what makes the
  Lisp macro `osql-select` expand into its streaming, printing form
  ([QUERY_COMPILER.md §4.1](QUERY_COMPILER.md#41-from-parsed-statement-to-derived-function)).
- If the parser returns a language identifier, the stream switches parser (`change_language`,
  :227). This is how you move between AmosQL, Lisp and SQL at the prompt.

### Three pluggable parsers

`register_top` ([top.c:618](AmosNT_floq/system/C/top.c#L618)) registers each language with
`a_define_parser(name, parser, result_printer, initializer, finalizer)` (declared in
[system/include/amos.h](AmosNT_floq/system/include/amos.h)):

| Language | Parser | Result printer |
|---|---|---|
| `AmosQL` | `parseAmosQL` (:578) → bison `yyparse()` → `parse_return` | Lisp `print-amosql-result` |
| `Lisp` | `parseLispForm` (:540) → `readfn` | `a_print` |
| `SQL` | `parseSQL` (:606) → `SQLparse()` → `sql_statement` | Lisp `print-amosql-result` |

It also exports the parser to Lisp as `parse`, `parse-file` and `parse-stream`. **Loading a file uses
the same loop as the console**: `load-amosql` → `(parse-file file "AmosQL")` → `a_parse_filefn`
(:445) calls `parse_and_eval` until end of file. `parse` (`parsefn`, :485) does the same for a
string. Lisp's `amos-execute` and `prepare-query` both call it.

---

## 5. The grammars

All inputs go through a **`flexstream`** ([amos.h:41](AmosNT_floq/system/include/amos.h#L41)), which
wraps an Amos stream (console, file, socket or string) so that flex's `YY_INPUT` reads through
`a_flexstream_getc` ([top.c:234](AmosNT_floq/system/C/top.c#L234)). One lexer therefore serves every
kind of input.

**AmosQL**: [parser.y](AmosNT_floq/system/C/parser.y) (bison) and
[scanner.l](AmosNT_floq/system/C/scanner.l) (flex), generated into `parser_tab.c` / `lexyy.c`. The
grammar actions build Lisp lists directly with `cons`, `a_list` and `mksymbol`:

- The top rule (:1602) stores each statement in the global `parse_return` and calls `YYACCEPT`, so the
  parser returns one statement per call. `top` also accepts `lisp_stmt`, which is why raw Lisp forms
  work at the AmosQL prompt.
- `select_stmt1` (:791) builds `(osql-select …distinct… (items) …into… …from… …where…)`. This is the
  form the Lisp side receives.
- A bare expression statement such as `name(:p);` becomes `(osql-select (expr))`
  (`general_expr_query`, :1656). That is the shape `osql-callp` recognises for its no-compile fast
  path (QUERY_COMPILER.md §4.1).
- Inside `create function … as select …`, the same `select_stmt1` is reused with the head replaced
  by `select` (:680). That is the function-body form, not the ad hoc query form.

**SQL**: [sql_parser.y](AmosNT_floq/system/C/sql_parser.y) and
[sql_lexer.l](AmosNT_floq/system/C/sql_lexer.l), generated with the prefix `SQL` (`SQLparse`,
`SQLin`). It produces an AmosQL-equivalent Lisp form in `sql_statement`.
[SQLParse.c](AmosNT_floq/system/C/SQLParse.c) also exposes it to Lisp as `sql-parse`. (The rest of
the SQL front end is Lisp: `init.lsp` loads [SQL/project/init.lsp](AmosNT_floq/SQL/project/).)

[system/C/parse/](AmosNT_floq/system/C/parse/) (`EXP_parser.y`) is an unrelated stand-alone demo
parser.

---

## 6. The C ↔ Lisp bridge

**The evaluator contract** ([system/include/kernel.h](AmosNT_floq/system/include/kernel.h)):

```c
#define feval(env,xx) (listp(xx) ? evallist(fhd(xx),ftl(xx),env,xx,NULL,0)\
 : evalatom(env,xx,FALSE)) /* Fast evaluation macro */
```

It is a classic tree-walking interpreter. `bindtype` (`struct bindenv *`,
[storage.h](AmosNT_floq/C/storage.h)) is a single variable-binding stack (`varstack`) used as both
the Lisp call stack and the ObjectLog executor's stack. It is passed as `env` to nearly every kernel
function.

**C calls Lisp.** These are declared in [C/alisp.h](AmosNT_floq/C/alisp.h): `evalfn`, `applyfn`,
`eval_forms(env, "…")`, and above all `call_lisp(symbol, env, arity, args…)`. Examples:
- `amosql()` and `a_execute_custom` call Lisp `amos-execute`
  ([lsp/fncall.lsp:1148](AmosNT_floq/lsp/fncall.lsp#L1148)), which is just `(eval (parse *cmd*))`.
- The AmosQL result printer calls Lisp `print-amosql-result`.
- The C scan functions call Lisp `open-query-scan` / `scan-nextrow` (§7).

**Lisp calls C.** A built-in is an `extfncell` ([alisp.h:19](AmosNT_floq/C/alisp.h#L19)): an object
with tag `EXTFNTYPE` that holds the C function pointer `fnaddr` and an argument count. It is bound to
a symbol with `extfunction0` … `extfunction5`, `extfunctionn` (variable arity) or `extfunctionq`
(presumably unevaluated arguments: `evalargs` can be `NO_EVAL`, alisp.h:40). When `evallist` finds that a symbol is bound to an `EXTFNTYPE`, it calls
`fnaddr(env, arg1, …)`. The pattern is the same everywhere:

```c
void register_storagetypes(void)                         /* storagetypes.c:736 */
{ ...
  generatortype = a_definetype("generator",free_generator,NULL);   /* new type tag */
  extfunction3("make-generator", make_generatorfn);                /* new built-in */
```

Some other `register_*` functions that are useful to look at:

| Where | Registers |
|---|---|
| `typecheck.c:161` | `getbinding`, `arg-types`, `type-of-var`, `arg-type`: fast accessors for `typecheck.lsp` |
| `coroutine.c:931` | `coroutine`, `co-resume`, `co-select`, … |
| `lispfns.c:1081` | **`invoke-plan`** (`invoke_planfn`, :294): runs a sub-plan with `a_mapfunctionC`. This is the C end of the optimizer's `_invoke-plan_` operator ([optimizer.lsp:458](AmosNT_floq/lsp/optimizer.lsp#L458)) |
| `top.c:630` | `parse`, `parse-file`, `parse-stream` |

User-level foreign functions (AmosQL functions implemented in C) use the separate *callout*
interface in [C/callout.h](AmosNT_floq/C/callout.h), with `a_callcontext` and emitting results
through `a_result`. See your
[lisp-foreign-functions.md](../amos-query-optimization/lisp-foreign-functions.md) for the Lisp
version and the templates in [extenders/myAmosExtenders/](AmosNT_floq/extenders/myAmosExtenders/).

---

## 7. The embedding API (callin) and scans

[system/C/cinterf.c](AmosNT_floq/system/C/cinterf.c) implements [C/callin.h](AmosNT_floq/C/callin.h)
for programs that embed Amos or connect to it (e.g. the Python binding in
[embeddings/Python/](AmosNT_floq/embeddings/Python/) uses it):
`a_connect`, `a_execute`, `a_nextrow`, `a_getelem`, `a_createobject`, …

`a_execute_custom` ([cinterf.c:1159](AmosNT_floq/system/C/cinterf.c#L1159)) chooses one of five
paths:

| Connection | Condition | Path |
|---|---|---|
| local | `materialized_scan` (default **TRUE**) | `amos-execute` runs the whole query into a list |
| local | not a query | `amos-execute` |
| local | `materialized_scan` FALSE | `open_query_streamfn` → Lisp `open-query-scan`: a live cursor |
| remote | `materialized_remote_scan` (default TRUE) | Lisp `execute-remote-statement` over a socket |
| remote | otherwise | `open_query_stream_remotefn`: a remote live cursor |

**By default, results are materialized** (`cinterf.c:213–214`). The coroutine-based streaming mode
was added in 2012, and its changelog entry says "does not work fully yet" (:131).

**Cursors.** `struct scancell` ([system/include/scan.h:52](AmosNT_floq/system/include/scan.h#L52))
has `buffer`, `coroutine` and `socket` fields. A scan is backed by a materialized buffer, by a
coroutine that yields one row at a time, or by a server-side socket. The C functions in
[scan.c](AmosNT_floq/system/C/scan.c) (`open_query_streamfn` :218, `open_function_streamfn`, …) are
one-line `call_lisp` wrappers. The cursor logic itself lives in
[lsp/scan.lsp](AmosNT_floq/lsp/scan.lsp) (`open-query-scan` :94, `scan-nextrow` :159).

**Coroutines.** [coroutine.c](AmosNT_floq/system/C/coroutine.c) provides thread-backed coroutines to
Lisp (`coroutine`, `co-resume`, `co-yield`, …). They make the pull-based scan mode possible.

**Peers.** [comm.c](AmosNT_floq/system/C/comm.c) is a plain BSD-sockets layer exposed to Lisp. A
remote peer handles requests by calling `SERVER-EVAL` (:345, :691): Amos instances talk by sending
each other S-expressions to evaluate. The name server that `-n` / `-s` / `-c` register with sits on
top of this (see [CLAUDE.md](CLAUDE.md), "Running").

---

## 8. Running a plan

Taken together with QUERY_COMPILER.md, a compiled query runs like this:

1. `map-select` (Lisp) compiles the query into the function `_select_` and then calls
   `mapfunctionres` / `mapfunction` on it.
2. `mapfunction` and `mapfunction-apply` are built-ins registered by `olog.obj` (`mapfunctionfn`,
   `mapfunction_applyfn`). They read the function's `selectbody` and interpret its `optpred`, the
   TBR predicate (*inferred*, as §2).
3. Stored functions are read through `maprelation`
   ([amos.h](AmosNT_floq/system/include/amos.h), in `rel.obj`), using an index when the binding
   pattern allows it. The Lisp fast path `map-matching-function-extent`
   ([lsp/TBR.lsp:260](AmosNT_floq/lsp/TBR.lsp#L260)) calls `maprelation` directly for main-memory
   relations.
4. Foreign calls in the plan go to C function pointers (`extpred`) or Lisp functions, and results are
   emitted tuple by tuple to the caller's mapper (`a_emit`, `a_result`).
5. For a top-level query, the mapper is `print-tuple-line`, so rows print as they are produced.
   For `a_execute`, rows are collected into a list.

**Where the compiled plan is stored.** An Amos database object is a C `struct oidcell`
([amos.h:26](AmosNT_floq/system/include/amos.h#L26)). It holds a type list (most specific first), a
**property list** `propl`, and `next`/`prev` links through the extent of its type. The Lisp compiler
stores a function's `selectbody`, its `cost` and its per-binding-pattern `bindings` (TBRs) on that
property list: `(getobject fno 'selectbody)` reads it. So the plan is data attached to the function
object, and it is saved in the image along with everything else.

**Indexes are pluggable.** `struct index_properties`
([index.h:55](AmosNT_floq/system/include/index.h#L55)) is a table of function pointers: creator,
mapper, getter, inserter, deleter, counter, dropper. New index types are registered with
`define_index_type` into `index_types[20]`. The built-in hash index is in `rel.obj`; B-trees are in
`btree.obj`. The loadable extenders in [extenders/BTREE](AmosNT_floq/extenders/BTREE/) (`bt.so`) and
[extenders/XTREE](AmosNT_floq/extenders/XTREE/) (`xt.so`) plug in the same way. On the optimizer
side, an index type can also register an `index-rewriter`
([lsp/relation.lsp:78](AmosNT_floq/lsp/relation.lsp#L78)), which is how range access over a new
index gets into plans.

---

## 9. Memory and transactions

- **Reference counting**, not tracing GC: `a_let`, `a_setf`, `a_free`, `release`, `a_return` and
  `released` throughout `system/C` adjust `objtags.rcnt`. There is no separate collector in the
  source that is available here.
- **Undo log**: updates are logged with `history_addfn` (in `hist.obj`; its signature takes the
  event, object, argument and old/new values, amos.h). `history_rollbackfn` undoes back to a
  savepoint and `commitfn` makes changes permanent. The REPL uses this for per-statement
  rollback (§4).
- **Persistence is the image**: `save 'file.dmp'` writes the whole heap. There is no separate
  on-disk database format in the core.

---

## 10. Reading order and handoff points

Suggested order for reading the source:

1. [C/main.c](AmosNT_floq/C/main.c)
2. [init.c](AmosNT_floq/system/C/init.c): `init_amos`, `process_options`
3. [commands.c](AmosNT_floq/system/C/commands.c)
4. [top.c](AmosNT_floq/system/C/top.c): `amos_toploop`, `parse_and_eval`, `register_top`
5. [parser.y](AmosNT_floq/system/C/parser.y): the `top`, `select_stmt1` and `general_expr_query`
   rules
6. [lsp/fncall.lsp](AmosNT_floq/lsp/fncall.lsp): `osql-select` → `map-select`
7. The Lisp pipeline in [QUERY_COMPILER.md](QUERY_COMPILER.md)
8. Back to C: [C/callout.h](AmosNT_floq/C/callout.h), [amos.h](AmosNT_floq/system/include/amos.h),
   [index.h](AmosNT_floq/system/include/index.h) and [scan.h](AmosNT_floq/system/include/scan.h) for
   execution; [cinterf.c](AmosNT_floq/system/C/cinterf.c) for embedding

**Handoffs between C and Lisp:**

| Direction | C side | Lisp side |
|---|---|---|
| C → Lisp: run a statement | `parse_and_eval` → `evalfn` (top.c:332) | the parsed form, e.g. macro `osql-select` |
| C → Lisp: run a string | `amosql`, `a_execute_custom` → `call_lisp(amos_execute…)` | `amos-execute` (fncall.lsp:1148) |
| Lisp → C: parse | `parsefn`, `a_parse_filefn` (top.c:485, :445) | `parse`, `parse-file`, `load-amosql` |
| Lisp → C: run a plan | `mapfunctionfn`, `a_mapfunctionC` (olog.obj) | `mapfunction`, `mapfunction-apply` |
| Lisp → C: run a sub-plan | `invoke_planfn` (lispfns.c:294) | `_invoke-plan_` calls in TBR plans |
| Lisp → C: stored data | `maprelation` (rel.obj) | `map-matching-function-extent` (TBR.lsp:260) |
| Lisp → C: optimizer helpers | `coversfn`, `pred_bindsfn`, `argsbpatfn` (misc.obj) | `covers`, `pred_binds`, `argsbpat` |
| Lisp → C: type info | `register_typecheck_functions` (typecheck.c:161) | `arg-type`, `type-of-var`, … |
| C → Lisp: scans | `open_query_streamfn` (scan.c:218) | `open-query-scan` (scan.lsp:94) |
| C → Lisp: print result | `printAmosQLResult` (top.c:590) | `print-amosql-result` |
