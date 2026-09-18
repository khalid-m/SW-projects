#!/usr/bin/env python3
"""Generate LSP_FUNCTION_INDEX.md: every top-level defun/defmacro in AmosNT_floq/lsp/.

For each definition: name, kind, file:line, first line of its docstring, and whether
an AmosQL `as foreign '<name>'` declaration anywhere in lsp/ refers to it.
Files are listed in the order the image loads them (following (load "...") calls
from init.lsp), then files that nothing loads.

Usage (from Amos2/):  python3 tools/gen_lsp_index.py > LSP_FUNCTION_INDEX.md
"""
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "AmosNT_floq")
LSP = os.path.join(ROOT, "lsp")
LINK = "AmosNT_floq/lsp/"


def read(path):
    with open(path, "rb") as f:
        return f.read().decode("latin-1").replace("\r\n", "\n").replace("\r", "\n")


def strip_comments(text):
    """Blank out ;-comments and #|...|# blocks, keeping offsets and strings intact."""
    out, i, n = list(text), 0, len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c == ";":
            while i < n and text[i] != "\n":
                out[i] = " "
                i += 1
            continue
        elif text.startswith("#|", i):
            j = text.find("|#", i)
            j = n if j < 0 else j + 2
            for k in range(i, j):
                if out[k] != "\n":
                    out[k] = " "
            i = j
            continue
        i += 1
    return "".join(out)


def skip_ws(s, i):
    while i < len(s) and s[i].isspace():
        i += 1
    return i


def read_sexp_end(s, i):
    """Index just past the s-expression starting at s[i]."""
    if s[i] == "(":
        depth, in_str = 0, False
        while i < len(s):
            c = s[i]
            if in_str:
                if c == "\\":
                    i += 1
                elif c == '"':
                    in_str = False
            elif c == '"':
                in_str = True
            elif c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    return i + 1
            i += 1
        return i
    if s[i] == '"':
        return read_string(s, i)[1]
    while i < len(s) and not s[i].isspace() and s[i] not in "()":
        i += 1
    return i


def read_string(s, i):
    j, buf = i + 1, []
    while j < len(s) and s[j] != '"':
        if s[j] == "\\" and j + 1 < len(s):
            j += 1
        buf.append(s[j])
        j += 1
    return "".join(buf), j + 1


QUOTED_BLOCK = re.compile(r"^\(quote\b", re.M)


def quoted_ranges(s):
    """Ranges of top-level (quote ...) forms: code disabled by quoting."""
    ranges = []
    for m in QUOTED_BLOCK.finditer(s):
        ranges.append((m.start(), read_sexp_end(s, m.start())))
    return ranges


DEF_RE = re.compile(r"^\((defun|defmacro)\s+([^\s()]+)", re.M)


def definitions(path):
    raw = read(path)
    s = strip_comments(raw)
    disabled = quoted_ranges(s)
    for m in DEF_RE.finditer(s):
        kind, name = m.group(1), m.group(2)
        line = s.count("\n", 0, m.start()) + 1
        quoted = any(a <= m.start() < b for a, b in disabled)
        i = skip_ws(s, m.end())
        doc = ""
        if i < len(s):
            i = skip_ws(s, read_sexp_end(s, i))  # skip argument list
            if i < len(s) and s[i] == '"':
                doc, end = read_string(s, i)
                # a lone string as the whole body is the return value, not a docstring
                if s[skip_ws(s, end):skip_ws(s, end) + 1] == ")":
                    doc = ""
        yield kind, name, line, doc, quoted


LOAD_RE = re.compile(r'\(load\s+"([^"]+\.lsp)"')


def load_order():
    """Follow (load "x.lsp") calls from init.lsp, restricted to lsp/."""
    order, seen = [], set()

    def visit(fname):
        if fname in seen:
            return
        path = os.path.join(LSP, fname)
        if not os.path.isfile(path):
            return
        seen.add(fname)
        order.append(fname)
        for m in LOAD_RE.finditer(strip_comments(read(path))):
            target = m.group(1)
            if "/" not in target:
                visit(target)

    visit("init.lsp")
    return order


FOREIGN_RE = re.compile(r"as\s+foreign\s+'([^']+)'", re.I)


def foreign_names():
    names = set()
    for f in os.listdir(LSP):
        if f.endswith((".lsp", ".osql", ".amosql")):
            for m in FOREIGN_RE.finditer(read(os.path.join(LSP, f))):
                names.add(m.group(1).lower())
    return names


def md(text):
    return text.replace("|", "\\|").replace("<", "&lt;").replace(">", "&gt;")


def main():
    files = sorted(f for f in os.listdir(LSP) if f.endswith(".lsp"))
    loaded = load_order()
    unloaded = [f for f in files if f not in loaded]
    foreign = foreign_names()

    defs = {f: list(definitions(os.path.join(LSP, f))) for f in files}
    where = defaultdict(list)
    for f in loaded + unloaded:
        for kind, name, line, doc, quoted in defs[f]:
            if not quoted:
                where[name.lower()].append((f, line))

    total = sum(1 for f in files for d in defs[f] if not d[4])
    documented = sum(1 for f in files for d in defs[f] if not d[4] and d[3])
    out = sys.stdout.write

    out("# `lsp/` function index\n\n")
    out("Every top-level `defun` and `defmacro` in [AmosNT_floq/lsp/](AmosNT_floq/lsp/), generated by\n")
    out("[tools/gen_lsp_index.py](tools/gen_lsp_index.py). Do not edit by hand; rerun the script.\n")
    out("For how the pieces fit together see [QUERY_COMPILER.md](QUERY_COMPILER.md).\n\n")
    out(f"- **{total}** definitions in **{len(files)}** files; **{documented}** have a docstring.\n")
    out(f"- Files appear in **image load order**, i.e. the order their loading starts when following `(load …)` from `init.lsp`: "
        f"{len(loaded)} loaded, then {len(unloaded)} that nothing in `lsp/` loads.\n")
    out("- Only loads inside `lsp/` are followed. Some \"unloaded\" files are loaded from elsewhere "
        "(e.g. AQIT, wrappers, experiment scripts) or by hand.\n")
    out("- **FF**: an AmosQL `as foreign '<name>'` declaration in `lsp/` refers to this function.\n")
    out("- **Also in**: the same name is defined elsewhere too. Among loaded files the one loaded "
        "*last* wins.\n")
    out("- Definitions inside a top-level `(quote …)` block are disabled and not listed.\n")
    out("- Docstrings are cut to their first line.\n\n")

    out("## Files\n\n| # | File | Defs | Loaded |\n|---|---|---|---|\n")
    for k, f in enumerate(loaded + unloaded, 1):
        n = sum(1 for d in defs[f] if not d[4])
        ref = f"[{f}](#{f.replace('.', '').lower()})" if n else f
        out(f"| {k} | {ref} | {n} | "
            f"{'yes' if f in loaded else 'no'} |\n")
    out("\n")

    for f in loaded + unloaded:
        live = [d for d in defs[f] if not d[4]]
        if not live:
            continue
        tag = "" if f in loaded else "*Not loaded from `lsp/`.*\n\n"
        out(f"## {f}\n\n{tag}| Function | Line | Docstring | FF | Also in |\n|---|---|---|---|---|\n")
        for kind, name, line, doc, _ in live:
            first = doc.strip().split("\n")[0].strip() if doc else ""
            if len(first) > 110:
                first = first[:107].rstrip() + "..."
            others = [f"{g}:{l}" for g, l in where[name.lower()] if (g, l) != (f, line)]
            label = f"`{md(name)}`" + (" *(macro)*" if kind == "defmacro" else "")
            out(f"| {label} | [{line}]({LINK}{f}#L{line}) | {md(first)} | "
                f"{'FF' if name.lower() in foreign else ''} | {md(', '.join(others[:3]))}"
                f"{' …' if len(others) > 3 else ''} |\n")
        out("\n")


if __name__ == "__main__":
    main()
