# Amos II source documentation

Documentation for [AmosNT_floq/](AmosNT_floq/), a 2013–14 checkout of the **Amos II** database system
(Uppsala University, UDBL) together with about 40 research extensions. Everything here was written by
reading the source; nothing was run, because this checkout has no working build on a current machine
([KERNEL.md §2](KERNEL.md#2-what-has-source-and-what-doesnt)).

## Where to start

1. **[DIRECTORY_MAP.md](DIRECTORY_MAP.md)**: what each of the ~40 top-level directories is, and which
   ones matter.
2. **[QUERY_COMPILER.md](QUERY_COMPILER.md)**: how a query becomes a plan. This is the core of the
   system.
3. **[KERNEL.md](KERNEL.md)**: the C side: startup, the prompt loop, parsing, the C↔Lisp bridge, and
   how a plan runs.
4. Then, as needed:
   - [STORAGE.md](STORAGE.md): what the data is;
   - [OPTIMIZER.md](OPTIMIZER.md): where the cost numbers come from;
   - [DTR_AQIT.md](DTR_AQIT.md): two plan-changing mechanisms;
   - [BIGINTEGRATOR.md](BIGINTEGRATOR.md): external sources and FLOQ.

Keep [GLOSSARY.md](GLOSSARY.md) open alongside. The docs use terms like TR, TBR, binding pattern,
resolvent and source predicate throughout.

## Documents

**Written by hand**

| Document | Covers |
|---|---|
| [DIRECTORY_MAP.md](DIRECTORY_MAP.md) | Every top-level directory: purpose, key files, status (core / active / legacy) |
| [QUERY_COMPILER.md](QUERY_COMPILER.md) | `lsp/`: parse → flatten → TR → rewrite → view expansion → cost-based ordering → TBR plan; the `selectbody` struct; worked example |
| [OPTIMIZER.md](OPTIMIZER.md) | Cost model in detail with a hand calculation; `ranksort` / `exhaustive` / `randomopt`; AmosQL optimizer controls; rewrite rules in practice; plan reuse and recompilation |
| [DTR_AQIT.md](DTR_AQIT.md) | Late binding of overloaded functions (DTR and compiled dispatch); AQIT inequality transformation, its 18 algebraic rules, and distance-based index rewriting |
| [STORAGE.md](STORAGE.md) | Objects and types, stored functions as views over hidden relations, updates and transactions, image persistence, indexes, MEXIMA and the extenders |
| [KERNEL.md](KERNEL.md) | `system/`: the three layers, what is binary-only, startup, REPL, grammars, C↔Lisp bridge, client API, scans, plan execution |
| [BIGINTEGRATOR.md](BIGINTEGRATOR.md) | The absorber/finalizer mediator framework, the relational wrapper and its SQL generation, and FLOQ |
| [GLOSSARY.md](GLOSSARY.md) | About 60 terms, each linked to where it is explained |
| [CLAUDE.md](CLAUDE.md) | Build, run and test commands and a short architecture summary (read by Claude Code) |

**Generated from the source** (don't edit by hand; see *Regenerating* below)

| Document | Lists | Generator |
|---|---|---|
| [AMOSQL_FUNCTIONS.md](AMOSQL_FUNCTIONS.md) | The AmosQL functions the standard image defines: what a user can call | [gen_amosql_functions.py](tools/gen_amosql_functions.py) |
| [LSP_FUNCTION_INDEX.md](LSP_FUNCTION_INDEX.md) | Every `defun`/`defmacro` in `lsp/`, in image load order, with docstrings | [gen_lsp_index.py](tools/gen_lsp_index.py) |
| [C_API.md](C_API.md) | The public C API in `C/*.h`, with where each function is implemented (source or binary module) | [gen_c_api.py](tools/gen_c_api.py) |
| [C_BUILTINS.md](C_BUILTINS.md) | Every Lisp built-in registered from `system/C` | [gen_c_builtins.py](tools/gen_c_builtins.py) |
| [GRAMMAR_MAP.md](GRAMMAR_MAP.md) | Each AmosQL grammar rule → the Lisp form it builds → its handler | [gen_grammar_map.py](tools/gen_grammar_map.py) |
| [REWRITE_RULES.md](REWRITE_RULES.md) | Every rewrite-rule registration, marked by whether it is in the standard image | [gen_rewrite_rules.py](tools/gen_rewrite_rules.py) |

## Regenerating

```sh
sh tools/regenerate.sh
```

This rewrites all six generated files from `AmosNT_floq/` (Python 3; `nm` is needed for the
binary-module column of `C_API.md`). Run it after changing the source, or after changing a generator.

## Conventions used in these docs

- **Paths** in links are relative to this folder, so source files are under `AmosNT_floq/…`. Line
  numbers refer to this checkout.
- **Verified vs. inferred.** Statements about binary-only kernel modules (evaluator, storage, plan
  executor) come from headers and symbol tables and are marked *inferred*. Worked examples are
  calculated or reconstructed from the code, not captured from a running system, and say so.
- **Encoding.** Many source files are ISO-8859 with CRLF line endings. Plain `grep` may skip them as
  binary; use `grep -a`. The generators read them correctly.
- **What "loaded" means.** Several directories contain old copies, Emacs backups and experiments. The
  docs say which files the standard image `bin/amos2.dmp` actually loads (see
  [BIGINTEGRATOR.md §1](BIGINTEGRATOR.md#1-what-is-live-and-what-isnt) and the "Image" columns of
  the generated files).

## Related material in this repository

- [../amos-query-optimization/](../amos-query-optimization/): notes on the optimizer from the outside
  (plan transcripts, the Litwin & Risch 1992 paper, rewrite-rule experiments, the MongoDB wrapper,
  the Polars comparison). The docs here link to them where they meet.
- [../uu-db2-assign3-extensible-index/](../uu-db2-assign3-extensible-index/): the extensible-index
  (KDTREE) lab, which uses the AQIT rewrite matrix described in [DTR_AQIT.md §2.5](DTR_AQIT.md#25-distance-predicates-and-the-rewrite-matrix).
- [../Amos-II-docs/](../Amos-II-docs/): the official Amos II manuals and papers.
