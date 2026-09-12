# Run log — AMOS II (Windows 11 VM)

Raw transcripts from running AMOS II for this assignment, in an actual
`amos2`/`Javaamos` session on a Windows 11 VM. Per the working convention in
[`../CLAUDE.md`](../CLAUDE.md), any claim about AMOS II behavior written into
the tutorials or the assignment README must be backed by real output pasted
here first — nothing should be written up as fact from documentation or
assumption alone.

Append new sessions at the bottom, most recent last. Each entry should
capture enough to reproduce and verify the result later: what was run, the
full unedited output, and a one-line takeaway.

---

## Entry template

```
### YYYY-MM-DD — <short title>

**Setup:** (AMOS II version/dump loaded, e.g. `amos2 wc.dmp`, any prior
`(load ...)` or `optmethod(...)` state)

**Command(s):**
    <exact AmosQL / ALisp input>

**Output:**
    <exact, unedited transcript>

**Takeaway:** <one line — what this confirms or contradicts>
```

---

### 2026-09-12 — initial session start (two builds, side by side)

Running both AMOS II builds on the Windows 11 VM in parallel, to compare
behavior between the version the Örebro assignment specifies and the newer
build also available on the machine.

**Setup A — older build** (per the Örebro assignment's "use the older
version from Assignment 4" note), launched from:

    C:\Users\klmah\Desktop\Amos-related\older-amos2\bin>amos2

Version banner: `Amos II Release 8, v2`.

**Command(s):**
    Amos 1> < "../demo/tutorial.amosql";

**Output:**
    Amos II Release 8, v2
    Amos 1> < "../demo/tutorial.amosql";
    Reading AMOSQL from "../demo/tutorial.amosql"
    Reading AMOSQL from "../demo/wcdata.amosql"
    "../demo/tutorial.amosql"
    0.112 s

**Takeaway:** Older build is confirmed AMOS II Release 8, v2. Loading
`tutorial.amosql` transitively loads `wcdata.amosql` (the World Cup demo
data this assignment needs) from the same `demo/` directory — so the World
Cup schema/data is already available in this session without loading
`wcdata.amosql` separately.

**Command(s):**
    save "wc.dmp";

**Output:**
    Amos 2> Undefined variable: DMP
    Amos 2> save "wc.dmp";
    "wc.dmp"
    0.004 s
    Amos 1>

**Takeaway:** `save "wc.dmp";` successfully dumps the now-loaded World Cup
database to `wc.dmp` (matches the Linköping lab's `amos2 wc.dmp` startup
convention). The preceding `Undefined variable: DMP` error is from an
earlier/different input line (likely `save wc.dmp;` without quotes, parsed
as a bareword `DMP`) — confirm exact prior command if this needs
documenting as a gotcha.

**Command(s):**
    exit;
    (restart from shell)
    amos2 wc.dmp

**Output:**
    Amos 1> exit;

    C:\Users\klmah\Desktop\Amos-related\older-amos2\bin>amos2 wc.dmp
    Amos II Release 8, v2
    Amos 1>

**Takeaway:** Confirms the Linköping lab's exact startup convention works
on this build: `amos2 wc.dmp` reopens the dumped World Cup database
directly, restoring the loaded schema/data from the saved session without
needing to re-run `tutorial.amosql`/`wcdata.amosql`.

**Command(s):**
    create function matches_in_1950() -> Match as select m
    from match m
    where spectators(m)>100000
    and year(played_in(m))=1950;

    matches_in_1950();

    pc("matches_in_1950");

**Output:**
    Amos 1> create function matches_in_1950() -> Match as select m
    from match m
    where spectators(m)>100000
    and year(played_in(m))=1950;
    #[OID 1234 "MATCHES_IN_1950->MATCH"]
    0.019 s
    Amos 2> matches_in_1950();
    #[OID 1187]
    #[OID 1184]
    #[OID 1189]
    #[OID 1188]
    0.002 s
    Amos 2> pc("matches_in_1950");
    ----------------------------
    Original definition of MATCHES_IN_1950->MATCH:
    (CREATE-FUNCTION #[OID 1234 "MATCHES_IN_1950->MATCH"] NIL
       ((MATCH _V1))
       AS
       (M)
       FOREACH
       ((MATCH M))
       WHERE
       (AND (> (SPECTATORS M)
               100000)
            (= (YEAR
                  (PLAYED_IN M))
               1950)))

    Simplified:
    (MATCHES_IN_1950->MATCH M+) <-
    (AND (MATCH.SPECTATORS->INTEGER M _V2)
         (MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Normalized and simplified:
    (MATCHES_IN_1950->MATCH M+) <-
    (AND (P_MATCH.SPECTATORS->INTEGER M _V2)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Coerced: same

    Decomposed (TBR):
    (MATCHES_IN_1950->MATCH M+) <-
    (AND (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_MATCH.SPECTATORS->INTEGER M _V2)
         (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V2 100000))
    #[OID 1234 "MATCHES_IN_1950->MATCH"]
    0.027 s
    Amos 2>

**Takeaway:** `pc(...)` on this build shows more optimizer stages than the
`objlog` example in the Linköping PDF documented (Original →
**Simplified** → **Normalized and simplified** → Coerced → **Decomposed
(TBR)**), but the end state matches the lab's expected optimized-plan shape
exactly: the stock (non-`dynprogsort`) optimizer already reorders this
query to `year` first, then `played_in`, then `spectators`, then the `>`
test as a `CALL GT--` boolean check — same predicate order and same
`CALL GT--` boundification the Linköping PDF's worked example (l2) shows
for its `answer` query. Confirms this build's default 'greedy' optimizer
picks the cheap-first ordering unassisted for this particular query; the
real test of `dynprogsort`/`optmethod('exhaustive')` will be a query where
the default heuristic and exhaustive search could plausibly disagree.

---

**Setup B — newer build**, launched from:

    C:\Users\klmah\Desktop\Amos-related\AmosNT_floq\bin>amos2

Version banner: `Release 16, v11`. Prompt is `AmosQL n>` (not `Amos n>` as
in the older build).

**Command(s):**
    < "../demo/tutorial.amosql";
    save "wc.dmp";
    exit;
    (restart from shell) amos2 wc.dmp
    pc("matches_in_1950");

**Output:**
    AmosQL 1> < "../demo/tutorial.amosql";
    Reading AmosQL statements from "../demo/tutorial.amosql"
    Reading AmosQL statements from "../demo/wcdata.amosql"
    "../demo/tutorial.amosql"
    0.086 s
    AmosQL 1> save "wc.dmp";
    "wc.dmp"
    0.005 s
    AmosQL 1> exit;

    C:\Users\klmah\Desktop\Amos-related\AmosNT_floq\bin>amos2 wc.dmp
    Release 16, v11
    AmosQL 2> pc("matches_in_1950");
    ----------------------------
    matches_in_1950()->Match

    Execution plan:
    (MATCHES_IN_1950->MATCH M+) <-
    (NESTED-LOOP-JOIN
       (HASH-FULL-SCAN #[OID 1515 "TOURNAMENT.YEAR->INTEGER"] _V3+ 1950)
       (HASH-FULL-SCAN #[OID 1549 "MATCH.PLAYED_IN->TOURNAMENT"] M+ _V3-)
       (HASH-INDEX-GET #[OID 1552 "MATCH.SPECTATORS->INTEGER"] M- _V2+)
       (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] _V2- 100000))
    #[OID 1751 "MATCHES_IN_1950->MATCH"]
    0.015 s
    AmosQL 2>

**Takeaway:** Confirms newer build is Release 16, v11 (vs. Release 8, v2 for
the older build), with a differently-labeled prompt (`AmosQL n>` vs.
`Amos n>`) and a load message wording change ("Reading AmosQL statements
from" vs. "Reading AMOSQL from") — cosmetic differences, not behavioral.

Same `tutorial.amosql`/`save "wc.dmp"`/`amos2 wc.dmp` workflow reproduces
identically on this build.

**`pc()` output format differs substantially between builds** — this is the
important finding, not just cosmetic:
- Older build (Release 8, v2) prints multiple optimizer *stages* (Original →
  Simplified → Normalized and simplified → Coerced → Decomposed (TBR)) as
  flat ObjectLog predicate lists, with no named physical operators — the
  final "Decomposed" stage is the closest analog to a plan but never names
  index-access methods like `HASH-*`.
- Newer build (Release 16, v11) prints a single, much more informative
  **"Execution plan"** directly in terms of physical operators —
  `NESTED-LOOP-JOIN` wrapping `HASH-FULL-SCAN` / `HASH-INDEX-GET` /
  `CALL #extpred ...#` — which is the `<STRUCTURE>-<OPERATION>` naming
  convention this repo's tutorials document (see
  [`../tutorial-index-execution-plans.md`](../tutorial-index-execution-plans.md)).

**Comparison:** the newer build's `pc()` is what the tutorial's existing
examples assume (`HASH-INDEX-GET`, `HASH-FULL-SCAN`, etc.) — so for
producing/verifying execution-plan output to write into the tutorial or the
exercise 7 report, prefer running `pc()` on the **newer build**
(`AmosNT_floq`). Note also: predicate order in this plan is
`year → played_in → spectators → GT--`, matching both the older build's
Decomposed stage and the Linköping PDF's worked example — same optimizer
decision, different plan representation.

**Setup:** back on the older build (Release 8, v2), entered the ALisp
sub-interpreter with `lisp;` (per the Linköping PDF's `lisp;` /
`:osql` toggle).

**Command(s):**
    lisp;
    (objlog "select m from match m where spectators(m)>100000 and
    year(played_in(m))=1950;")

**Output:**
    Amos 3> lisp;
    lisp 3> (objlog "select m from match m where spectators(m)>100000 and year(played_in(m))=1950;")
    ----------------------------
    Original definition of NIL:
    (CREATE-FUNCTION *TRANSIENT* NIL
       ((OBJECT _V1))
       AS
       (M)
       FOREACH
       ((MATCH M))
       WHERE
       (AND (> (SPECTATORS M)
               100000)
            (= (YEAR
                  (PLAYED_IN M))
               1950)))

    Simplified:
    (NIL M+) <-
    (AND (MATCH.SPECTATORS->INTEGER M _V2)
         (MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Normalized and simplified:
    (NIL M+) <-
    (AND (P_MATCH.SPECTATORS->INTEGER M _V2)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Coerced: same

    Decomposed (TBR):
    (NIL M+) <-
    (AND (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_MATCH.SPECTATORS->INTEGER M _V2)
         (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V2 100000))
    #[OID TRANSIENT 3636920]
    0.035 s
    lisp 4>

**Takeaway:** `lisp;` correctly drops into the ALisp sub-prompt (`lisp n>`)
on the older build, confirming the Linköping PDF's `lisp;`/`:osql` toggle
still works on Release 8, v2. `(objlog "<query>;")` compiles an anonymous
(unnamed → `*TRANSIENT*`/`NIL`) query on the fly rather than requiring a
named stored function first — useful for probing binding-specific plans
without `create function`, which is exactly the workaround
[`../CLAUDE.md`](../CLAUDE.md) already documents for `pc()` (`pc()` only
shows a function's own default binding pattern). Output stages are
otherwise identical in structure to the `pc("matches_in_1950")` run above,
just with `NIL` standing in for the (absent) function name — reconfirms
this build's `pc`/`objlog` never names physical index operators, only
predicate order and binding pattern (`M+`), unlike the newer build's
`HASH-*` execution plan.

**Setup:** newer build (Release 16, v11), `wc.dmp` loaded, entered ALisp via
`lisp;`.

**Command(s):**
    lisp;
    (objlog "select m from match m where spectators(m)>100000 and
    year(played_in(m))=1950;")

**Output:**
    AmosQL 2> lisp;
    Lisp 2> (objlog "select m from match m where spectators(m)>100000 and year(played_in(m))=1950;")
    ----------------------------
    *select*()->Match

    Original definition:
    (CREATE-FUNCTION #[OID 36 "*SELECT*"] NIL NIL AS
       (#[OID 1527]
          (OPTNULL #[OID 1522])))

    Simplified:
    (*SELECT* M+) <-
    (AND (SPECTATORS M _V5)
         (> _V5 100000)
         (PLAYED_IN M _V6)
         (YEAR _V6 1950))

    Normalized and simplified:
    (*SELECT* M+) <-
    (AND (SPECTATORS M _V5)
         (> _V5 100000)
         (PLAYED_IN M _V6)
         (YEAR _V6 1950))

    Final TR: same

    Absorbed: same

    TBR:
    (*SELECT* M+) <-
    (AND (YEAR _V6 1950)
         (PLAYED_IN M _V6)
         (SPECTATORS M _V5)
         (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] _V5 100000))

    Execution plan:
    (*SELECT* M+) <-
    (NESTED-LOOP-JOIN
       (HASH-FULL-SCAN #[OID 1515 "TOURNAMENT.YEAR->INTEGER"] _V6+ 1950)
       (HASH-FULL-SCAN #[OID 1549 "MATCH.PLAYED_IN->TOURNAMENT"] M+ _V6-)
       (HASH-INDEX-GET #[OID 1552 "MATCH.SPECTATORS->INTEGER"] M- _V5+)
       (CALL #extpred "GT--"# #[OID 202 "OBJECT.OBJECT.>->BOOLEAN"] _V5- 100000))
    NIL
    0.044 s
    Lisp 3>

**Takeaway:** NOT the same shape as either prior `objlog`/`pc` transcript —
this is a third, distinct format. Differences from the older build's
`objlog` output on the identical query:
- Named `*select*()->Match` / OID 36 `*SELECT*` instead of `NIL` for the
  anonymous query — this build names ad hoc queries `*SELECT*` rather than
  leaving them `NIL`.
- Stage names differ: **Final TR** and **Absorbed** appear where the older
  build had "Coerced"; **TBR** (predicate order + binding pattern, no
  physical ops — same shape as the older build's "Decomposed (TBR)") is
  followed by an additional **Execution plan** stage the older build never
  produces at all — this is where the `HASH-*`/`NESTED-LOOP-JOIN` operators
  finally appear, identical to the `pc("matches_in_1950")` output on this
  same build.
- Confirms `objlog` on the newer build is strictly more informative than
  the older build's `objlog`/`pc`: it shows every intermediate stage *and*
  the final physical execution plan in one call, whereas the older build's
  output stops at the logical (TBR/Decomposed) stage and never reaches
  physical operators.
- Predicate order is again `year → played_in → spectators → GT--`, so the
  underlying optimizer decision is unchanged across all three transcripts of
  this same query — only the reporting format and stage names vary
  build-to-build.

**Setup:** older build (Release 8, v2), `wc.dmp` loaded, inside `lisp;`.
Reproducing the "Various optimization functions" worked examples from the
Linköping PDF against the real World Cup data.

**Command(s):**
    (setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 1950))
    (simple-pred-cost pred '(+ -))
    (setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 '_v3))
    (bindadornpat pred '(_v3))
    (substbindadorned
      (list (getfunctionnamed 'object.object.>->boolean) '_v1 10000)
      '(- -))
    (setq pred (list (getfunctionnamed 'number.number.plus->number) 17 42 '_v1))

**Output:**
    lisp 4> (setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 1950))
    WARNING! Setting undeclared global variable: PRED
    (#[OID 1001 "P_TOURNAMENT.YEAR->INTEGER"] _V2 1950)
    0.002 s
    lisp 4> (simple-pred-cost pred '(+ -))
    (28 . 1.0)
    lisp 4> (setq pred (list (getfunctionnamed 'p_tournament.year->integer) '_v2 '_v3))
    WARNING! Setting undeclared global variable: PRED
    (#[OID 1001 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
    lisp 4> (bindadornpat pred '(_v3))
    (+ -)
    lisp 4> (substbindadorned
    (list(getfunctionnamed 'object.object.>->boolean)'_v1 10000)
    '(- -))
    (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V1 10000)
    lisp 4> (setq pred (list (getfunctionnamed 'number.number.plus->number) 17 42 '_v1))
    WARNING! Setting undeclared global variable: PRED
    (#[OID 107 "NUMBER.NUMBER.PLUS->NUMBER"] 17 42 _V1)
    0.002 s
    lisp 4>

**Takeaway:** All four PDF worked examples reproduce correctly on real data,
with one numeric discrepancy worth flagging:
- `(simple-pred-cost pred '(+ -))` for `year(tournament)->integer` under
  binding `fb` (free tournament arg, bound year `1950`) returns
  `(28 . 1.0)` here — **cost 28 matches the PDF's cost model exactly**
  (`2 × 14 tuples = 28`, per the cost-model section: "there exist a table
  ... with ... 14 tuples"), confirming the World Cup dataset in this
  session still has exactly 14 tournaments. However the PDF's own
  `simple-pred-cost` example (`(50 . 1.78571)`) uses different numbers than
  its cost-model section's worked description (28, fanout 1) for the
  *same* predicate/binding — the PDF is internally inconsistent on this
  example, and this run's real output (28, 1.0) matches the cost-model
  prose, not the `simple-pred-cost` example table. Use **28 / 1.0** (this
  run's real, reproduced number) as the trusted value, not the PDF's
  `(50 . 1.78571)`.
- `getfunctionnamed`, `bindadornpat`, and `substbindadorned` all behave
  exactly as documented — `bindadornpat` with `_v3` bound returns `(+ -)`
  (var 1 free, var 2 bound), and `substbindadorned` on binding `(- -)`
  correctly rewrites `object.object.>->boolean` into the physical
  `(CALL GT-- ...)` form seen in every execution plan above.
- The `WARNING! Setting undeclared global variable: PRED` messages are
  cosmetic ALisp style-checking noise from `setq`ing an unquoted global
  without a prior `defvar`/`let` — harmless for interactive debugging, but
  `dynprogsort` itself avoids this by binding `pred` inside a `let`/`dolist`
  rather than with a bare top-level `setq`.

**Setup:** older build, `wc.dmp` loaded, inside `lisp;`. Testing
`bindadornpat`/`pred_binds` interactively while working out blank 8/9/10
context and the `:bound` field for `lab7.lsp`.

**Command(s) and output (chronological):**

    Lisp 1> (bindadornpat pred '(_V3))
    (+ -)
    Lisp 1> (bindadornpat (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3) '(_V3))
    Error 15, Undefined function: #[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"]
    When evaluating: (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
    (FAULTEVAL BROKEN)
    At *BOTTOM* brk>(bindadornpat '(#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3) '(_V3))
    (+ -)
    (FAULTEVAL BROKEN)
    At *BOTTOM* brk>

    (setq pred2 (list (getfunctionnamed 'P_MATCH.PLAYED_IN->TOURNAMENT) 'M '_V3))
    WARNING! Setting undeclared global variable: PRED2
    (#[OID 1550 "P_MATCH.PLAYED_IN->TOURNAMENT"] M _V3)
    Lisp 1> (bindadornpat '(#[OID 1550 "P_MATCH.PLAYED_IN->TOURNAMENT"] M _V3) '(_V3))
    (+ -)

    Lisp 2> (bindadornpat '(#[OID 1550 "P_MATCH.PLAYED_IN->TOURNAMENT"] M _V2) '(_V2))
    (+ -)
    Lisp 2> (bindadornpat '(#[OID 1550 "P_MATCH.PLAYED_IN->TOURNAMENT"] M _V2) '(_V2 _V3))
    (+ -)
    Lisp 2>

**Takeaways:**
- **Unquoted predicate literal → "Undefined function" error.** Writing a
  predicate list directly as an argument without quoting it,
  `(bindadornpat (#[OID 1516 ...] _V2 _V3) '(_V3))`, makes the Lisp reader
  treat `(#[OID 1516 ...] _V2 _V3)` as a *function call* (parens always mean
  "call" unless quoted) — it tries to call the OID reference as a function
  name and fails with `Error 15, Undefined function`. Fix: quote the whole
  list, `'(#[OID 1516 ...] _V2 _V3)`, exactly the same quoting rule already
  established for bare symbols (`'_v2`) — it applies to whole lists too.
  Evaluating a corrected, quoted expression *inside* the resulting
  break-loop (`brk>`) works fine and returns the right answer (`(+ -)`),
  but the session stays in `FAULTEVAL BROKEN` until `:c` (continue) or `:r`
  (reset) is issued — evaluating successfully inside a break-loop does not
  itself clear it.
- **Wrong join variable slips through undetected by `bindadornpat` alone.**
  `pred2` was built with `_V3` (the *year* variable, from the earlier
  `year(tournament)->integer(_V2, _V3)` predicate) instead of `_V2` (the
  *tournament* variable) as `played_in`'s second argument — semantically
  wrong, since `played_in(match)->tournament` should join to the same
  tournament the year predicate resolved, not to the year value itself.
  `bindadornpat` still happily returned `(+ -)` for this wrong predicate,
  because it only checks "is this argument's variable present in the given
  bound-list," with zero semantic awareness of what a variable represents —
  a self-consistent but wrong test (bound-list `'(_V3)` was hand-picked to
  match the mistake) will still "pass." Corrected version uses `_V2`
  throughout, matching the PDF's own worked ObjectLog program
  (`(P_MATCH.PLAYED_IN->TOURNAMENT M _V2)` alongside
  `(P_TOURNAMENT.YEAR->INTEGER _V2 1950)`).
- **Extra, irrelevant bound variables are harmless.**
  `(bindadornpat '(...M _V2) '(_V2))` and
  `(bindadornpat '(...M _V2) '(_V2 _V3))` both return `(+ -)` — adding
  `_V3` to the bound-list changes nothing, since `pred2` (correct version)
  never mentions `_V3` at all. Confirms it's always safe to pass the full,
  accumulated `oldbound` (every variable bound by every predicate placed so
  far in the plan) to `bindadornpat` for whichever candidate predicate is
  being considered next — no need to filter `oldbound` down to only the
  variables a given predicate cares about; this is exactly what the real
  `dynprogsort` loop does (line 25's `(bindadornpat pred oldbound)`, with
  `oldbound` being the full accumulated set from `(planinfo-bound
  bestplan)`).

**Setup:** older build, fresh session (`amos2 wc.dmp`). First attempt at
actually running `dynprogsort` for real, after all 10 blanks were filled
in `lab7.lsp`.

**Command(s) and output (chronological):**

    C:\Users\klmah\Desktop\Amos-related\older-amos2\bin>amos2 wc.dmp
    Amos II Release 8, v2
    Amos 1> lisp;
    lisp 1> (objlog "select m from match m where spectators(m)>100000 and
    year(played_in(m))=1950;")
    ----------------------------
    Original definition of NIL:
    (CREATE-FUNCTION *TRANSIENT* NIL
       ((OBJECT _V1))
       AS
       (M)
       FOREACH
       ((MATCH M))
       WHERE
       (AND (> (SPECTATORS M)
               100000)
            (= (YEAR
                  (PLAYED_IN M))
               1950)))

    Simplified:
    (NIL M+) <-
    (AND (MATCH.SPECTATORS->INTEGER M _V2)
         (MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Normalized and simplified:
    (NIL M+) <-
    (AND (P_MATCH.SPECTATORS->INTEGER M _V2)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (OBJECT.OBJECT.>->BOOLEAN _V2 100000))

    Coerced: same

    Decomposed (TBR):
    (NIL M+) <-
    (AND (P_TOURNAMENT.YEAR->INTEGER _V3 1950)
         (P_MATCH.PLAYED_IN->TOURNAMENT M _V3)
         (P_MATCH.SPECTATORS->INTEGER M _V2)
         (CALL GT-- #[OID 121 "OBJECT.OBJECT.>->BOOLEAN"] _V2 100000))
    #[OID TRANSIENT 3407504]
    0.036 s
    lisp 2> :osql
    Amos 2> optmethod('ranksort');
    "RANKSORT"
    0.012 s
    Amos 3> lisp;
    lisp 3> (load "lab7.lsp")
    Loading "lab7.lsp"
    (DYNPROGSORT REDEFINED)
    "lab7.lsp"
    0.037 s
    lisp 3> :osql
    Amos 3> optmethod('exhaustive');
    "RANKSORT"
    Amos 4> create function matches_in_1950() -> Match as select m
    from match m
    where spectators(m)>100000
    and year(played_in(m))=1950;
    Error 15, Undefined function: MAKE-PLANINFO
    0.01 s
    Amos 4>

**Takeaways:**
- **`objlog` at the very start doesn't reveal the current `optmethod`
  setting** — it only shows whatever the currently-active optimizer
  produces, never which mode it's in. `optmethod` has no separate
  "just tell me" query form; the only way to learn the current setting is
  to call it (which also sets a new value) and read the *old* value it
  returns.
- **`optmethod('ranksort');` returned `"RANKSORT"`** — confirming a fresh
  `amos2 wc.dmp` session starts on the documented default
  (`"ranksort"`), exactly as the manual states, before any switch was ever
  made.
- **`(load "lab7.lsp")` succeeded** — printed `(DYNPROGSORT REDEFINED)`,
  confirming the function loaded and replaced any prior definition, with no
  load-time syntax/paren errors (consistent with the mechanical paren-
  balance check done earlier on the file).
- **`optmethod('exhaustive');` returned `"RANKSORT"`** — confirms the mode
  really did just switch from ranksort to exhaustive by this call (matches
  the earlier check, since nothing else had changed it in between).
- **`create function matches_in_1950() ...` failed:
  `Error 15, Undefined function: MAKE-PLANINFO`.** This is the first real
  invocation of `dynprogsort` (creating/optimizing the function under
  exhaustive mode triggers it) — and it reveals that **the `planinfo`
  struct itself was never defined** in this session. `defstruct` is what
  auto-generates `make-planinfo` and the field accessors
  (`planinfo-plan`, etc.) — but only once
  `(defstruct planinfo plan bound rem cost fanout)` has actually been
  evaluated. The PDF documents the struct's *shape* as a reference, but
  does not supply it as a pre-loaded built-in on this build, and
  `lab7.lsp`/`kodskelett.lsp` never included the `defstruct` form itself.
  None of the earlier interactive tests (`bindadornpat`, `pred_binds`,
  `simple-pred-cost`) ever called `make-planinfo`, which is why this gap
  went unnoticed until the first real end-to-end run.
- **Fix identified (not yet applied/verified):** add
  `(defstruct planinfo plan bound rem cost fanout)` to `lab7.lsp`, before
  `dynprogsort` is defined (or at least before it's ever called), then
  reload and retry `create function matches_in_1950() ...`.

**Setup:** older build, fresh session (`amos2 wc.dmp`). Retried after two
fixes to `lab7.lsp`: (1) added
`(defstruct planinfo plan bound rem cost fanout)` right after the
`_use_dnf_` line, before `dynprogsort` is defined; (2) fixed a second,
separate bug found along the way — blank 2's `cond` clause was
`( null queue (amos-error ...))`, missing an inner pair of parens around
`null queue`, so `null` was being evaluated as a bare, unbound *variable*
reference rather than called as a function — producing
`Error 1, Unbound variable: NULL` on the very next attempt (not shown
verbatim here, but between the two logged transcripts). Fixed to
`((null queue) (amos-error ...))`.

**Command(s) and output:**

    C:\Users\klmah\Desktop\Amos-related\older-amos2\bin>amos2 wc.dmp
    Amos II Release 8, v2
    Amos 1> optmethod('ranksort');
    "RANKSORT"
    0.008 s
    Amos 2> lisp;
    lisp 2> (load "lab7.lsp")
    Loading "lab7.lsp"
    (DYNPROGSORT REDEFINED)
    "lab7.lsp"
    0.002 s
    lisp 2> :osql
    Amos 2> optmethod('exhaustive');
    "RANKSORT"
    Amos 3> create function matches_in_1950() -> Match as select m
    from match m
    where spectators(m)>100000
    and year(played_in(m))=1950;
    #[OID 1234 "MATCHES_IN_1950->MATCH"]
    0.006 s
    Amos 4>

**Takeaway:** **First clean, error-free run of `dynprogsort` end-to-end.**
`create function matches_in_1950() ...` — which triggers query
optimization at creation time (as seen in every earlier `pc()` transcript,
where the "Decomposed (TBR)" stage was already present immediately after
`create function`) — completed with no error under `optmethod('exhaustive')`
and the fully-filled-in `dynprogsort` loaded. Both structural bugs found
along the way (`MAKE-PLANINFO` undefined, then `null` unbound) are now
fixed and confirmed not to recur.

This does **not yet prove** `dynprogsort` was actually the code path that
ran, just that nothing crashed — it's possible (if unlikely, given
`optmethod('exhaustive')` was just confirmed active) that some other
codepath handled this silently. **Next verification step:** run
`(trace dynprogsort)` before creating/reoptimizing the function, to get
direct, unambiguous confirmation it was invoked, and compare
`pc("matches_in_1950")`'s resulting plan — note this particular query's
predicate order (`year → played_in → spectators → GT--`) was already found
by the *default* greedy optimizer in every earlier run (see the
`matches_in_1950`/`pc()` transcripts above), so a matching plan here
wouldn't by itself prove exhaustive search changed anything — only the
`trace` output (or a query where greedy and exhaustive plausibly disagree)
gives real evidence `dynprogsort` specifically produced this result.
