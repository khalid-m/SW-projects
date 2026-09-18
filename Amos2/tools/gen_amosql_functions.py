#!/usr/bin/env python3
"""Generate AMOSQL_FUNCTIONS.md: the AmosQL functions defined by the standard image.

Four ways system functions are defined, all parsed here:
  1. AmosQL `create function ...;` statements in .osql/.amosql files loaded by the image
  2. the same statements inside (osql "...") strings in loaded Lisp files
  3. (foreign-lispfn name ((type var)...) ((type var)...) "doc" body...)    Lisp macro
  4. (create-function name ((type var)...) (...) as foreign ...)          Lisp macro

Files covered: lsp/ files in image load order (see gen_lsp_index.load_order) and the
.osql/.amosql files they load, plus the files outside lsp/ that init.lsp loads (MEXIMA, AQIT,
BigIntegrator, wrappers). Other subsystems (SCSQ, SciSPARQL, ...) are not covered.

Usage (from Amos2/):  python3 tools/gen_amosql_functions.py > AMOSQL_FUNCTIONS.md
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_lsp_index as lspidx  # noqa: E402

ROOT = lspidx.ROOT

# Loaded outside lsp/: see STORAGE.md §7.3, BIGINTEGRATOR.md §1, lsp/init.lsp.
EXTRA = [
    "system/C/mexima/lsp/mex-basic.lsp", "system/C/mexima/lsp/mex-lisp-interfaces.lsp",
    "system/C/mexima/lsp/mex-transactional.lsp", "system/C/mexima/lsp/mex-utilities.lsp",
    "system/C/mexima/lsp/mex-amos-interfaces.lsp", "system/C/mexima/lsp/mex-relation-save-restore.lsp",
    "system/C/mexima/lsp/mex-save-restore.lsp",
    "BigIntegrator/src/Lisp/integrator.lsp", "BigIntegrator/src/AmosQL/integrator.amosql",
    "BigIntegrator/src/AmosQL/meta_data.amosql", "BigIntegrator/src/Lisp/accessfilter.lsp",
    "BigIntegrator/src/Lisp/wrapperfuncs.lsp", "BigIntegrator/src/Lisp/absorbmng.lsp",
    "BigIntegrator/src/Lisp/misc.lsp", "BigIntegrator/src/Lisp/finalizermng.lsp",
    "wrappers/datasource/typemap.osql", "wrappers/datasource/typemap.lsp",
    "wrappers/datasource/core-cluster.lsp", "wrappers/datasource/core-cluster.osql",
    "wrappers/relational/relational.lsp", "wrappers/relational/relational.osql",
    "wrappers/relational/sqlquery.lsp", "wrappers/relational/import-table.lsp",
    "wrappers/relational/metadata.lsp", "wrappers/relational/sql.lsp",
    "wrappers/relational/relational_typemap.osql", "wrappers/relational/sql_constructor.lsp",
    "wrappers/relational/configuration.osql", "wrappers/relational/sql_finalizer.lsp",
    "wrappers/relational/numwrapper.lsp", "wrappers/relational/patch.lsp",
    "wrappers/JDBC/jdbc.lsp", "wrappers/JDBC/jdbc.osql",
] + [f"aqit/lsp/{f}.lsp" for f in (
    "aqit_utilities", "ud-index-cc", "late-tr-rewrite", "miscv2", "algebraic-rules", "aqitv2",
    "rewrite-matrix", "dist-based-index-rewrite2", "rewrite-index-phases")]

LOAD_AMOSQL_RE = re.compile(r'\(load-amosql\s+"([^"]+\.(?:osql|amosql))"')
CF_RE = re.compile(r"\bcreate\s+function\s+", re.I)
FLF_RE = re.compile(r"^\(foreign-lispfn\s+", re.M)
LCF_RE = re.compile(r"^[ \t]*\(create-function\s+", re.M)


def image_files():
    files = []
    for f in lspidx.load_order():
        files.append("lsp/" + f)
        for m in LOAD_AMOSQL_RE.finditer(lspidx.strip_comments(lspidx.read(os.path.join(lspidx.LSP, f)))):
            if "/" not in m.group(1) and os.path.exists(os.path.join(lspidx.LSP, m.group(1))):
                files.append("lsp/" + m.group(1))
    for f in EXTRA:
        if os.path.exists(os.path.join(ROOT, f)):
            files.append(f)
    seen, out = set(), []
    for f in files:
        if f not in seen:
            seen.add(f)
            out.append(f)
    return out


def balanced(s, i, open_="(", close=")"):
    """s[i] == open_; index just past the matching close (ignores quotes)."""
    depth = 0
    while i < len(s):
        if s[i] == open_:
            depth += 1
        elif s[i] == close:
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return i


def squash(t):
    return " ".join(t.replace('\\"', '"').split())


def parse_create_function(s, i):
    """Parse an AmosQL 'create function' statement at s[i:] (after the keywords).
    Returns (signature, impl, comment) or None."""
    m = re.match(r"([A-Za-z_][\w]*)\s*", s[i:])
    if not m or not s[i + m.end():].startswith("("):
        return None
    name = m.group(1)
    j = i + m.end()
    k = balanced(s, j)
    sig = name + squash(s[j:k])
    end = s.find(";", k)
    end = len(s) if end < 0 else end
    stmt = s[k:end]
    comment = ""
    cm = re.search(r"/\*(.*?)\*/", stmt, re.S)
    am = re.search(r"\bas\b", stmt, re.I)
    if cm and (not am or cm.start() < am.start() or cm.start() - am.end() < 3):
        comment = squash(cm.group(1))
    head = stmt[: am.start()] if am else stmt
    head = re.sub(r"/\*.*?\*/", " ", head, flags=re.S)
    rm = re.match(r"\s*->\s*(.*)", head, re.S)
    if rm:
        sig += " -> " + squash(rm.group(1))
    impl = "stored (no `as` clause)"  # AmosQL default, cf. the abstract-function docstring
    if am:
        rest = re.sub(r"/\*.*?\*/", " ", stmt[am.end():], flags=re.S).strip()
        fm = re.match(r"foreign\s+'([^']+)'", rest, re.I)
        if fm:
            impl = f"foreign `{fm.group(1)}`"
        else:
            word = (re.match(r"[A-Za-z_]+", rest) or [""])[0].lower()
            impl = {"stored": "stored", "select": "derived", "multidirectional": "multidirectional",
                    "begin": "procedure", "for": "procedure", "set": "procedure", "if": "procedure",
                    "return": "procedure", "foreign": "foreign"}.get(word, "derived")
    return sig, impl, comment


def parse_lisp_decls(s, i):
    """Parse '((type var) ...)' declaration list at s[i]; return 'Type var, ...'."""
    i = lspidx.skip_ws(s, i)
    if i >= len(s) or s[i] != "(":
        return "", i
    j = lspidx.read_sexp_end(s, i)
    inner = s[i + 1:j - 1]
    parts = []
    for d in re.findall(r"\(([^()]*)\)", inner):
        toks = d.split()
        if toks:
            parts.append(" ".join(t.capitalize() if n == 0 else t for n, t in enumerate(toks)))
    return ", ".join(parts), j


def docstring_ranges(s):
    """(start, end) of every defun/defmacro docstring: examples there are not definitions."""
    out = []
    for m in lspidx.DEF_RE.finditer(s):
        i = lspidx.skip_ws(s, m.end())
        if i < len(s):
            i = lspidx.skip_ws(s, lspidx.read_sexp_end(s, i))
            if i < len(s) and s[i] == '"':
                out.append((i, lspidx.read_string(s, i)[1]))
    return out


def functions_in(path):
    raw = lspidx.read(os.path.join(ROOT, path))
    is_lisp = path.endswith(".lsp")
    s = lspidx.strip_comments(raw) if is_lisp else raw
    disabled = (lspidx.quoted_ranges(s) + docstring_ranges(s)) if is_lisp else []
    live = lambda p: not any(a <= p < b for a, b in disabled)
    line = lambda p: s.count("\n", 0, p) + 1
    out = []
    for m in CF_RE.finditer(s):
        if not live(m.start()):
            continue
        if not is_lisp and s.rfind("/*", 0, m.start()) > s.rfind("*/", 0, m.start()):
            continue  # inside an AmosQL comment
        r = parse_create_function(s, m.end())
        if r:
            out.append((line(m.start()), *r))
    if is_lisp:
        for rx, kind in ((FLF_RE, "foreign-lispfn"), (LCF_RE, "create-function")):
            for m in rx.finditer(s):
                if not live(m.start()):
                    continue
                i = lspidx.skip_ws(s, m.end())
                j = lspidx.read_sexp_end(s, i)
                name = s[i:j]
                args, j = parse_lisp_decls(s, j)
                res, j = parse_lisp_decls(s, j)
                doc = ""
                k = lspidx.skip_ws(s, j)
                if kind == "foreign-lispfn" and k < len(s) and s[k] == '"':
                    doc = squash(lspidx.read_string(s, k)[0])
                sig = f"{name}({args})" + (f" -> ({res})" if res else "")
                impl = "foreign Lisp (`foreign-lispfn`)" if kind == "foreign-lispfn" else "Lisp `create-function`"
                if kind == "create-function":
                    fm = re.search(r"as\s+foreign\s+\(?'?\(?([^\s()]+)", s[j:lspidx.read_sexp_end(s, m.start() + len(m.group(0)) - len(m.group(0).lstrip()))], re.I)
                    if fm:
                        impl = f"foreign `{fm.group(1)}`"
                out.append((line(s.index("(", m.start())), sig, impl, doc))
    return sorted(out)


def main():
    files = image_files()
    rows = {f: functions_in(f) for f in files}
    rows = {f: r for f, r in rows.items() if r}
    total = sum(len(r) for r in rows.values())
    names = set()
    for r in rows.values():
        for _, sig, _, _ in r:
            names.add(re.match(r"[^\s(]+", sig).group(0).lower())

    area = lambda f: f.split("/")[0] if not f.startswith("system/") else "MEXIMA"
    w = sys.stdout.write
    w("# AmosQL system functions\n\n")
    w("The AmosQL functions that the standard image defines: what a user can call. Generated by\n")
    w("[tools/gen_amosql_functions.py](tools/gen_amosql_functions.py). Do not edit by hand; rerun the script.\n\n")
    w(f"- **{total}** definitions ({len(names)} distinct names; overloaded names have several rows) in "
      f"**{len(rows)}** files.\n")
    w("- Covers `lsp/` files in image load order and the `.osql`/`.amosql` files they load, plus the MEXIMA,\n"
      "  AQIT, BigIntegrator and wrapper files that `init.lsp` loads. Other subsystems (SCSQ, SciSPARQL, …)\n"
      "  define many more functions and are not covered.\n")
    w("- Four definition forms are parsed: AmosQL `create function` statements (in AmosQL files or in\n"
      "  `(osql \"…\")` strings inside Lisp), `(foreign-lispfn …)` and Lisp `(create-function …)`.\n")
    w("- **Implementation**: `stored` (a relation, [STORAGE.md §3](STORAGE.md#3-stored-functions-and-their-relations)),\n"
      "  `derived` (a query), `procedure`, `multidirectional`, or `foreign` with the implementing Lisp or C\n"
      "  function. For foreign names, look them up in [LSP_FUNCTION_INDEX.md](LSP_FUNCTION_INDEX.md) or\n"
      "  [C_BUILTINS.md](C_BUILTINS.md).\n")
    w("- **Comment** is the `/* … */` comment of the definition, or a `foreign-lispfn` docstring.\n"
      "  Signatures are shown as parsed; Lisp-form types are capitalized for readability.\n\n")

    w("## Files\n\n| Area | File | Functions |\n|---|---|---|\n")
    for f in rows:
        anchor = re.sub(r"[^a-z0-9_ -]", "", f.lower())
        w(f"| {area(f)} | [{f}](#{anchor}) | {len(rows[f])} |\n")
    w("\n")
    for f, r in rows.items():
        w(f"## {f}\n\n| Function | Implementation | Comment | Line |\n|---|---|---|---|\n")
        for ln, sig, impl, comment in r:
            c = comment if len(comment) <= 140 else comment[:137].rstrip() + "..."
            w(f"| `{lspidx.code(sig)}` | {lspidx.md(impl) if not impl.startswith('foreign `') else impl} | "
              f"{lspidx.md(c)} | [{ln}](AmosNT_floq/{f}#L{ln}) |\n")
        w("\n")


if __name__ == "__main__":
    main()
