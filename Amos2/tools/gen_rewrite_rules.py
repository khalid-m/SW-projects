#!/usr/bin/env python3
"""Generate REWRITE_RULES.md: every rewrite-rule registration in AmosNT_floq/.

Five registration forms are found:
  TR     (define-tr-rewriter 'fn 'test 'action)                 logical, before cost-based optimization
  late TR (define-late-tr-rewriter fn 'test 'action)            logical, after view expansion (AQIT)
  TBR    (add-rewriter fn bpat rewriter)                        physical, inside the greedy loop
  index  (putprop '<indextype> 'index-rewriter '<fn>)           TBR rewriter added with each index
  AmosQL ('<bpat>' foreign '<impl>' rewriter '<fn>')            TBR rewriter in a multidirectional function

For each: file:line, target, binding pattern, rewriter function(s), where those functions are defined
(with their docstring's first line), and whether the file is part of the standard image.

Usage (from Amos2/):  python3 tools/gen_rewrite_rules.py > REWRITE_RULES.md
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_lsp_index as lspidx  # noqa: E402

ROOT = lspidx.ROOT
SKIP = re.compile(r"(/CVS/|~\d*~$|/#[^/]*#$)")

FORMS = {  # registration form -> (kind, number of arguments)
    "define-tr-rewriter": ("TR", 3),
    "define-late-tr-rewriter": ("late TR", 3),
    "add-rewriter": ("TBR", 3),
}
FORM_RE = re.compile(r"\((" + "|".join(map(re.escape, FORMS)) + r")\s+")
IDX_RE = re.compile(r"\(putprop\s+'([^\s()]+)\s+'index-rewriter\s+'([^\s()]+)\s*\)")
OSQL_RE = re.compile(r"\(\s*'([bf-]+)'\s+foreign\s+'([^']+)'\s+rewriter\s+'([^']+)'", re.I)

# Files loaded into the standard image outside lsp/ (see BIGINTEGRATOR.md §1, STORAGE.md §7.3).
IMAGE_EXTRA = {"wrappers/datasource/core-cluster.lsp"} | {
    f"aqit/lsp/{f}.lsp" for f in (  # loaded by aqit/lsp/boot-aqit.lsp from init.lsp
        "aqit_utilities", "ud-index-cc", "late-tr-rewrite", "miscv2", "algebraic-rules",
        "aqitv2", "rewrite-matrix", "dist-based-index-rewrite2", "rewrite-index-phases")}


def all_files():
    for d, dirs, fs in os.walk(ROOT):
        dirs.sort()
        for f in sorted(fs):
            p = os.path.join(d, f)
            if f.endswith((".lsp", ".osql", ".amosql")) and not SKIP.search(p):
                yield p


def split_args(s, i, n):
    """Read n s-expressions starting at s[i]; return their texts."""
    out = []
    for _ in range(n):
        i = lspidx.skip_ws(s, i)
        if i >= len(s) or s[i] == ")":
            break
        j = i
        while j < len(s) and s[j] in "'#`,":  # quote prefixes belong to the next expression
            j += 1
        j = lspidx.read_sexp_end(s, j)
        out.append(" ".join(s[i:j].split()))
        i = j
    return out


def url(path):
    """Link target for a path; parentheses would end the Markdown link."""
    return path.replace("(", "%28").replace(")", "%29")


def main():
    rel = lambda p: os.path.relpath(p, ROOT)
    image = set(lspidx.load_order())
    texts = {p: lspidx.read(p) for p in all_files()}

    defs = {}
    for p, t in texts.items():
        if p.endswith(".lsp"):
            for kind, name, line, doc, quoted in lspidx.definitions(p):
                if not quoted:
                    defs.setdefault(name.lower().lstrip("'"), []).append((rel(p), line, doc))

    rows = []
    for p, raw in texts.items():
        t = lspidx.strip_comments(raw) if p.endswith(".lsp") else raw
        disabled = lspidx.quoted_ranges(t) if p.endswith(".lsp") else []
        live = lambda pos: not any(a <= pos < b for a, b in disabled)
        ln = lambda pos: t.count("\n", 0, pos) + 1
        for m in FORM_RE.finditer(t):
            if not live(m.start()):
                continue
            kind, n = FORMS[m.group(1)]
            args = split_args(t, m.end(), n)
            if len(args) == n:
                if kind == "TBR":
                    rows.append((kind, rel(p), ln(m.start()), args[0], args[1], [args[2]]))
                else:
                    rows.append((kind, rel(p), ln(m.start()), args[0], "", [args[1], args[2]]))
        for m in IDX_RE.finditer(t):
            if live(m.start()):
                rows.append(("index", rel(p), ln(m.start()), f"index type {m.group(1)}", "all free", [m.group(2)]))
        for m in OSQL_RE.finditer(t):
            rows.append(("AmosQL", rel(p), ln(m.start()), f"impl {m.group(2)}", m.group(1),
                         ["rewrite-" + m.group(3)]))  # define-tbr, TBR.lsp:434

    def in_image(path):
        if path.startswith("lsp/"):
            return os.path.basename(path) in image
        return path in IMAGE_EXTRA

    def fn_cell(names):
        cells = []
        for n in names:
            key = n.strip("'#").lower()
            d = defs.get(key)
            if d and not key.startswith("("):
                f, line, doc = d[0]
                first = (doc.strip().split("\n")[0] if doc else "")[:90]
                cells.append(f"`{n}` [{os.path.basename(f)}:{line}](AmosNT_floq/{url(f)}#L{line})"
                             + (f": {lspidx.md(first)}" if first else ""))
            else:
                cells.append(f"`{lspidx.md(n)}`")
        return "<br>".join(cells)

    w = sys.stdout.write
    w("# Rewrite-rule catalogue\n\n")
    w("Every rewrite-rule registration in [AmosNT_floq/](AmosNT_floq/), generated by\n")
    w("[tools/gen_rewrite_rules.py](tools/gen_rewrite_rules.py). Do not edit by hand; rerun the script.\n")
    w("How TR and TBR rules work: [QUERY_COMPILER.md §6](QUERY_COMPILER.md#6-two-kinds-of-rewrite-rules)\n")
    w("and [OPTIMIZER.md §4](OPTIMIZER.md#4-rewrite-rules-in-practice).\n\n")
    w("| Kind | Registered with | Runs |\n|---|---|---|\n")
    w("| **TR** | `(define-tr-rewriter 'fn 'test 'action)` | during each `rewrite` pass (`inferequals`), before cost-based optimization; one per function |\n")
    w("| **TBR** | `(add-rewriter fn bpat rewriter)` | inside the greedy loop (`rewrite-preds`), once bindings are known |\n")
    w("| **late TR** | `(define-late-tr-rewriter fn 'test 'action)` | TR rules applied only after view expansion (`call-late-tr-rewriters1`); installed by AQIT, [aqit/lsp/late-tr-rewrite.lsp](AmosNT_floq/aqit/lsp/late-tr-rewrite.lsp) |\n")
    w("| **index** | `(putprop '<type> 'index-rewriter 'fn)` | added as a TBR rewriter on each relation that gets an index of that type (`addindex0`) |\n")
    w("| **AmosQL** | `('<bpat>' foreign '<impl>' rewriter '<fn>')` in `create function … as multidirectional` | a TBR rewriter declared with the function; `rewriter 'x'` registers the Lisp function `rewrite-x` (`define-tbr`, [TBR.lsp:412](AmosNT_floq/lsp/TBR.lsp#L412)) |\n\n")
    w("**Image** = the file is loaded into the standard `amos2.dmp` (followed from `init.lsp`, plus the few\n")
    w("files outside `lsp/` that `init.lsp` loads). Other rows belong to extensions, wrappers or experiments\n")
    w("that load their own code. Several registrations sit inside a function body (e.g. `addindex0`,\n")
    w("`define-tbr`) and only run when that function is called. For a TBR rule, the rewriter's binding pattern uses `-` = bound and `+` =\n")
    w("free; AmosQL patterns use `b` = bound and `f` = free. Registrations built from variables show the\n")
    w("expression as written.\n\n")

    order = {"TR": 0, "late TR": 1, "index": 2, "TBR": 3, "AmosQL": 4}
    rows.sort(key=lambda r: (not in_image(r[1]), r[1].split("/")[0], order[r[0]], r[1], r[2]))
    w(f"{len(rows)} registrations, {sum(1 for r in rows if in_image(r[1]))} of them in the standard image.\n\n")
    w("| Kind | Where | Image | Target | Binding pattern | Rewriter / test + action |\n|---|---|---|---|---|---|\n")
    for kind, path, line, target, bpat, fns in rows:
        w(f"| {kind} | [{path}:{line}](AmosNT_floq/{url(path)}#L{line}) | {'yes' if in_image(path) else ''} | "
          f"`{lspidx.md(target)}` | {('`' + lspidx.md(bpat) + '`') if bpat else ''} | {fn_cell(fns)} |\n")


if __name__ == "__main__":
    main()
