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

---

**Setup B — newer build**, launched from:

    C:\Users\klmah\Desktop\Amos-related\AmosNT_floq\bin>amos2

**Command(s):**
    (awaiting output)

**Output:**
    (awaiting output)

**Takeaway:** (awaiting output)

**Comparison:** (once both have output — note any differences in version
banner, available index types, `dynprogsort`/`optmethod` support, etc.)
