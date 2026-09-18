# Glossary

Terms used across the Amos II docs in this folder, as they are meant *in this codebase*. Each entry
links to where it is explained. Doc abbreviations: **QC** = [QUERY_COMPILER.md](QUERY_COMPILER.md),
**OPT** = [OPTIMIZER.md](OPTIMIZER.md), **K** = [KERNEL.md](KERNEL.md), **ST** =
[STORAGE.md](STORAGE.md), **BI** = [BIGINTEGRATOR.md](BIGINTEGRATOR.md).

For individual Lisp functions see [LSP_FUNCTION_INDEX.md](LSP_FUNCTION_INDEX.md). For C built-ins see
[C_BUILTINS.md](C_BUILTINS.md).

| Term | Meaning | See |
|---|---|---|
| **`/` prefix** | Naming convention: `/createrelation`, `/addindex`, `/putprop`, … are the *transactional* versions, which log an undo event. The plain names do the same without logging. | [ST §4](STORAGE.md#transactions) |
| **absorbability** | The set of AmosQL functions (matched by name) that a data source can evaluate itself. Set per wrapper type or per data-source instance. | [BI §2](BIGINTEGRATOR.md#2-the-model) |
| **absorber** | A wrapper's Lisp function that claims the predicates its source can run, starting from a source predicate. Registered with `set_absorber`. The later Amos releases in your Mongo notes call it an *extractor* (inferred). | [BI §3](BIGINTEGRATOR.md#3-where-it-runs-in-the-optimizer), [§4.2](BIGINTEGRATOR.md#42-the-absorber-absorb-sql) |
| **access filter** | What an absorber's claim becomes in the plan: `(access-filter <expression> vars…)`, costed by a cost hint and later turned into a native query by the finalizer. | [BI §2](BIGINTEGRATOR.md#2-the-model), [§3.1](BIGINTEGRATOR.md#31-how-access-filters-are-costed) |
| **aLisp** | Amos II's own embedded Lisp. The evaluator is binary-only here; the query compiler is written in it. | [K §1](KERNEL.md#1-three-layers) |
| **Amos II** | The object-relational/functional DBMS from Uppsala University's UDBL lab. The whole checkout is Amos II plus research extensions. | [DIRECTORY_MAP.md](DIRECTORY_MAP.md) |
| **AmosQL / OSQL** | The query language. The grammar is in `system/C/parser.y`; `.osql` and `.amosql` files are AmosQL scripts. | [K §5](KERNEL.md#5-the-grammars), [GRAMMAR_MAP.md](GRAMMAR_MAP.md) |
| **AQIT** | Algebraic Query Inequality Transformation. Rewrites inequalities, including distance predicates, so that indexes can be used. On in the standard image, and it also installs the late TR rewriters. | [QC §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2) |
| **binding pattern (bpat)** | One symbol per argument/result position of a call. In Lisp **`-` = bound (input)** and **`+` = free (output)**; in AmosQL `multidirectional` clauses, `b` / `f`. | [QC §3](QUERY_COMPILER.md#binding-pattern-notation) |
| **BigIntegrator** | The 2012–13 mediator framework (absorber / finalizer) for pushing query parts into external sources. | [BI](BIGINTEGRATOR.md) |
| **callin / callout** | The C APIs for calling Amos from a host program (`C/callin.h`) and for implementing AmosQL functions in C (`C/callout.h`). | [K §6–7](KERNEL.md#6-the-c--lisp-bridge) |
| **core-cluster function** | Older name for a *source predicate*. | [BI §2](BIGINTEGRATOR.md#2-the-model) |
| **cost / fanout** | The optimizer's estimate for one evaluation of a predicate: the work it takes, and the number of result tuples. Fanout below 1 means a filter. | [OPT §2](OPTIMIZER.md#2-where-the-numbers-come-from) |
| **cost hint** | A declared `(cost fanout)`, or a cost function, for a function under a binding pattern (`declarecosts`). Used first when present. This is how foreign functions and wrappers report costs. | [OPT §2](OPTIMIZER.md#2-where-the-numbers-come-from) |
| **data source** | An instance of a wrapper type, e.g. one JDBC connection. In FLOQ it can be a *set* of connections. | [BI §2](BIGINTEGRATOR.md#2-the-model), [§6.2](BIGINTEGRATOR.md#62-modelling-the-log-databases-as-one-source) |
| **delpred** | A function's *update template*, the `selectbody` field naming the relation that updates write to. A function without one is not directly updatable. | [ST §3](STORAGE.md#3-stored-functions-and-their-relations), [§4](STORAGE.md#4-updates) |
| **derived function** | A function defined by a query (`create function … as select …`). Queries themselves are compiled as anonymous derived functions. | [QC §1](QUERY_COMPILER.md#1-the-pipeline-at-a-glance) |
| **DNF** | Disjunctive normal form. The TR predicate is normalized to it (`*use-dnf*`, on by default) before cost-based optimization. | [QC §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2) |
| **DTR / late binding** | Dynamic type resolver. When the resolvent of an overloaded call can't be chosen at compile time, a DTR call picks it at run time. On by default (`_USE_DTR_`). | [QC §4.2](QUERY_COMPILER.md#42-flattening-overload-resolution-and-type-checks-compileselect) |
| **ECA rules** | Event-condition-action triggers, compiled by `rule_compiler.lsp`. Disabled by default; not part of the optimizer. | [QC §9](QUERY_COMPILER.md#9-what-is-not-part-of-the-query-pipeline) |
| **extender** | A loadable shared library that adds an index type through MEXIMA: `bt` (MBTREE), `xt` (XTREE), Judy. | [ST §7.3](STORAGE.md#73-the-extenders) |
| **extent** | All objects of a type, kept as a linked list through the C `oidcell`s. It is not a stored table. | [ST §2](STORAGE.md#2-objects-and-types) |
| **`extfunction`** | How C registers a Lisp built-in: `extfunctionN("lisp-name", c_fn)` creates an `EXTFNTYPE` object bound to that symbol. | [K §6](KERNEL.md#6-the-c--lisp-bridge), [C_BUILTINS.md](C_BUILTINS.md) |
| **finalizer** | A wrapper's Lisp function that turns an access filter into a call to a native-query function, e.g. `sql@ds:'select …'`. Registered with `set_finalizer`. The finalizer manager then re-optimizes the whole plan. | [BI §3](BIGINTEGRATOR.md#3-where-it-runs-in-the-optimizer), [§4.3](BIGINTEGRATOR.md#43-the-finalizer-finalize-sql) |
| **flattening** | Turning nested calls such as `name(host(t))` into a conjunction of flat calls joined by fresh variables. Overload resolution happens during it. | [QC §4.2](QUERY_COMPILER.md#42-flattening-overload-resolution-and-type-checks-compileselect) |
| **flexstream** | The C wrapper that feeds any Amos stream (console, file, string, socket) to the flex scanners. | [K §5](KERNEL.md#5-the-grammars) |
| **FLOQ** | Minpeng Zhu's 2013–14 research on querying one metadata DB plus a collection of log DBs, run in parallel on Amos peers. Unfinished in this checkout. | [BI §6](BIGINTEGRATOR.md#6-floq) |
| **foreign function** | An AmosQL function implemented in C, Lisp or Java instead of by a query. It can have different implementations per binding pattern (multidirectional). | [QC §4.6](QUERY_COMPILER.md#46-choosing-the-implementation-bestmodefunction-and-substbindadorned) |
| **generic function / resolvent** | A function name such as `name` is *generic*. Each typed definition, such as `name(Person)` or `name(Country)`, is a *resolvent*. Overload resolution picks the most specific one. | [QC §4.2](QUERY_COMPILER.md#42-flattening-overload-resolution-and-type-checks-compileselect) |
| **history / savepoint** | The undo log (`hist.obj`). The REPL takes a savepoint around each statement and rolls it back if it fails; `commit` makes changes permanent. | [K §4](KERNEL.md#4-the-repl-and-parse-dispatch), [ST §4](STORAGE.md#transactions) |
| **image (`.dmp`)** | A saved Lisp heap: the compiled system plus the database. `bin/amos2.dmp` is the default. Persistence in Amos II means saving an image. | [K §3](KERNEL.md#3-startup), [ST §5](STORAGE.md#5-persistence-the-image) |
| **index rewriter** | A TBR rewriter attached to an index *type* (`(putprop '<type> 'index-rewriter 'fn)`). It is registered on each relation that gets such an index. | [ST §7.4](STORAGE.md#74-how-a-range-index-gets-into-a-plan-mbtree), [REWRITE_RULES.md](REWRITE_RULES.md) |
| **INVOKE-PLAN / sub-plan** | A section of a plan cut out into its own transient function and called through the `invoke-plan` built-in. | [OPT §5](OPTIMIZER.md#5-reusing-and-recompiling-plans) |
| **key group** | A set of argument positions declared as a key. TR rewriting uses key groups to unify duplicate lookups (`inferequals`). | [QC §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2), [ST §3](STORAGE.md#3-stored-functions-and-their-relations) |
| **late TR rewriter** | A TR rule applied only after view expansion (`define-late-tr-rewriter`). Installed by AQIT. | [REWRITE_RULES.md](REWRITE_RULES.md) |
| **mapped type** | An Amos type whose instances live in an external source, e.g. `SensorInstallation@A` for an imported SQL table. | [BI §4.1](BIGINTEGRATOR.md#41-importing-a-table-creates-a-source-predicate) |
| **`mapfunction` / `a_mapfunctionC`** | Run a function's compiled plan and pass each result tuple to a mapper. Implemented in the binary-only executor (`olog.obj`). | [K §8](KERNEL.md#8-running-a-plan) |
| **materialized scan** | The default way results reach a client: the whole result is computed into a list. The alternative is a coroutine-based cursor. | [K §7](KERNEL.md#7-the-embedding-api-callin-and-scans) |
| **MBTREE / XTREE / JUDY** | Index types added by the extenders: a main-memory B-tree with range scans, a multidimensional X-tree (k-NN), and Judy arrays. | [ST §7.3](STORAGE.md#73-the-extenders) |
| **MEXIMA / mexi** | The generic index-extension interface (`struct mexi_index_props`, with range scans). A *mexi* is the object that holds one such index. | [ST §7.2](STORAGE.md#72-mexima-the-generic-index-interface) |
| **multidirectional function** | A function with separate definitions per binding pattern, e.g. `("bbf" select …)`, `("fbf" select …)`, or `('bf' foreign 'impl' rewriter 'x' cost …)`. | [OPT §4](OPTIMIZER.md#4-rewrite-rules-in-practice) |
| **multisql** | FLOQ's case where one source predicate's data source is a *set* of databases. It is queried with `multi_sql_union` or a multicast. | [BI §6.2](BIGINTEGRATOR.md#62-modelling-the-log-databases-as-one-source) |
| **name server / peer** | Amos instances started with `-n` (name server), `-s` (server) or `-c` (client) register with a name server and call each other with `call_function` / `multicastreceive`. | [K §7](KERNEL.md#7-the-embedding-api-callin-and-scans), [BI §6.5](BIGINTEGRATOR.md#65-three-execution-strategies) |
| **ObjectLog** | The Datalog-like internal query representation: a conjunction/disjunction of calls. TR and TBR are its logical and physical forms. | [QC §1](QUERY_COMPILER.md#1-the-pipeline-at-a-glance), [litwin-risch-1992-objectlog.md](../amos-query-optimization/litwin-risch-1992-objectlog.md) |
| **`olog`** | The binary-only module that executes TBR plans (nested loops, union for OR, foreign calls). | [K §2](KERNEL.md#2-what-has-source-and-what-doesnt) |
| **OID / `oidtype` / `oidcell`** | Every value is an `oidtype` handle. A database object (surrogate) is a C `oidcell` with a type list, a property list and extent links. | [K §1](KERNEL.md#1-three-layers), [ST §2](STORAGE.md#2-objects-and-types) |
| **`optmethod`** | AmosQL control choosing the join-ordering strategy: `ranksort` (default), `exhaustive` or `randomopt`. | [OPT §1](OPTIMIZER.md#1-controlling-the-optimizer-from-amosql) |
| **`osql-select`** | The Lisp form a parsed `select` becomes. It is a macro that compiles the query according to context. | [QC §4.1](QUERY_COMPILER.md#41-from-parsed-statement-to-derived-function) |
| **partial evaluation** | Evaluating parts of a predicate with constant arguments at compile time, during TR rewriting (`*enable-parteval*`). | [OPT §1](OPTIMIZER.md#1-controlling-the-optimizer-from-amosql) |
| **`pc` / `objlog` / `qplan`** | Inspection functions: print a function's plans / compile a query string and print its plan / return a query's `optpred`. | [QC §8](QUERY_COMPILER.md#8-inspecting-plans) |
| **pre-optimized plan** | A callee's already-compiled plan spliced into the caller's plan if it is small enough (≤ 10 predicates). | [OPT §5](OPTIMIZER.md#5-reusing-and-recompiling-plans) |
| **proxy** | A local stand-in for an object in another Amos peer. | [ST §2](STORAGE.md#2-objects-and-types) |
| **rank** | `(fanout − 1) / cost`, the greedy ordering key of `ranksort`, from Litwin & Risch 1992. | [QC §4.5](QUERY_COMPILER.md#45-ordering-optimize-compound-predicate--psort), [OPT §3.1](OPTIMIZER.md#31-ranksort-default-greedy-by-rank) |
| **relation (`p_f`)** | The hidden main-memory table behind a stored function `f`. It has a width, one or more indexes, and `predof` pointing back to `f`. | [ST §3](STORAGE.md#3-stored-functions-and-their-relations) |
| **`selectbody`** | The struct holding one compiled function for one binding pattern: its predicate at each stage, the plan (`optpred`) and the update template (`delpred`). | [QC §3](QUERY_COMPILER.md#3-the-central-data-structure-selectbody) |
| **source predicate** | A function with no arguments that returns one external table's columns (`cclusterfct?`). The absorber starts from it. It still works as a full scan if nothing is absorbed. | [BI §2](BIGINTEGRATOR.md#2-the-model), [§4.1](BIGINTEGRATOR.md#41-importing-a-table-creates-a-source-predicate) |
| **stored function** | `create function … as stored`: a function that is a view over its own relation `p_f`. | [ST §3](STORAGE.md#3-stored-functions-and-their-relations) |
| **TBR** | The *physical* plan form: calls replaced by `(call <implementation> fn args…)` in a chosen order. Also the name of the per-binding-pattern `tbr` struct. | [QC §3](QUERY_COMPILER.md#3-the-central-data-structure-selectbody), [§4.6](QUERY_COMPILER.md#46-choosing-the-implementation-bestmodefunction-and-substbindadorned) |
| **TBR rewriter** | A rule that runs inside the greedy loop once bindings are known (`add-rewriter`). It returns `success` / `substitute` / `nil`. | [QC §6](QUERY_COMPILER.md#6-two-kinds-of-rewrite-rules), [OPT §4](OPTIMIZER.md#4-rewrite-rules-in-practice) |
| **TR** | The *logical* plan form: a conjunction of calls to resolved functions, with nothing yet chosen about execution. Stored in `selectbody-pred`. | [QC §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2) |
| **TR rewriter** | A logical rule applied during rewriting, before cost-based optimization (`define-tr-rewriter`), one per function. | [QC §6](QUERY_COMPILER.md#6-two-kinds-of-rewrite-rules), [OPT §4](OPTIMIZER.md#4-rewrite-rules-in-practice) |
| **transient object** | An object not saved with the database, e.g. `_select_` and generated query functions. | [ST §2](STORAGE.md#2-objects-and-types) |
| **`_select_`** | The reusable transient function every ad hoc query is compiled into. | [QC §4.1](QUERY_COMPILER.md#41-from-parsed-statement-to-derived-function) |
| **view expansion** | Inlining derived functions, and stored functions' relation predicates, into the query before optimization (`expand-predicate`). | [QC §4.3](QUERY_COMPILER.md#43-the-driver-compile_phase2) |
| **wrapper** | A *type* under `Datasource` whose instances are connections to one kind of external source. It carries an absorber and a finalizer. | [BI §2](BIGINTEGRATOR.md#2-the-model) |
