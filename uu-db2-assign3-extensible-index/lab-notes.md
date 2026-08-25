# Run Log — Assignment 3 (Extensible Database Indexing)

Environment: **Amos II Release 16, v11** (assignment doc examples were written against an
older release, but the behavior matches).

> **Environment note:** the `amos2.zip` distribution described in the assignment
> instructions could not be located. Instead, an **`AmosNT_floq`** build (which
> includes source code) was used, backed up at
> `/Volumes/WD4TB/WB-backup-2012-10/_check/_softwares-fixed/amos-backup/AmosNT_floq`
> on a 4TB external disk drive. The 32-bit JDK used
> (`jdk-7u80-windows-i586.exe`, see below) is also archived there, at
> `/Volumes/WD4TB/WB-backup-2012-10/_check/_softwares-fixed/amos-backup/lab3-java-32-bit/jdk-7u80-windows-i586.exe`,
> for future use. This was run on **Windows 11**, itself running inside a
> **VMware Fusion** VM. The assignment folder
> (`uu-db2-assign3-extensible-index`) was copied to the Windows desktop (as
> `DB2_3rdEx`) for local work.

## Environment setup: installing Java and running `amos2.exe` on Windows

### Problem: `amos2.exe` is a 32-bit executable

`amos2.exe` (the native launcher inside the AMOS II install, e.g. `AmosNT_floq\bin\`)
loads the JVM in-process via JNI, so its own architecture must match the JVM's
architecture exactly. Checked the executable's PE header `Machine` field from
PowerShell, no extra tools required:

```powershell
$path = "C:\Users\klmah\Desktop\AmosNT_floq\bin\amos2.exe"
$fs = [System.IO.File]::OpenRead($path)
$br = New-Object System.IO.BinaryReader($fs)
$fs.Seek(0x3C, 'Begin') | Out-Null
$peOffset = $br.ReadInt32()
$fs.Seek($peOffset + 4, 'Begin') | Out-Null
$machine = $br.ReadUInt16()
"{0:X}" -f $machine
$br.Close()
$fs.Close()
```

Result: `14C` — confirms **32-bit (x86)**. (`8664` would mean 64-bit/x64.) So a
64-bit JDK would fail to load (JNI/`jvm.dll` architecture mismatch); a 32-bit JDK is
required.

### Fix: install a 32-bit JDK

Oracle stopped publishing 32-bit JDK builds after Java 8, so a 32-bit **JDK 7 or 8**
build is needed. Used:

- **`jdk-7u80-windows-i586.exe`** ("i586" = Oracle's 32-bit x86 naming) downloaded
  from https://www.oracle.com/java/technologies/javase/javase7-archive-downloads.html
  (requires an Oracle account/license click-through for archived releases).
- Free alternatives without an account: Eclipse Adoptium (Temurin) or Azul Zulu,
  32-bit Windows builds.

Installed to the default location: `C:\Program Files (x86)\Java\jdk1.7.0_80`.

### Verifying the install

```powershell
Test-Path "C:\Program Files (x86)\Java\jdk1.7.0_80\bin\java.exe"
# True

$env:JAVA_HOME = "C:\Program Files (x86)\Java\jdk1.7.0_80"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
java -version
# java version "1.7.0_80"
# Java(TM) SE Runtime Environment (build 1.7.0_80-b15)
# Java HotSpot(TM) Client VM (build 24.80-b11, mixed mode, sharing)
```

"Client VM" with no "64-Bit" mentioned confirms the 32-bit build is active.

### Gotcha: PowerShell vs. `cmd.exe` syntax

`setup.cmd`/`assignment3.cmd` are `cmd.exe` batch files (`set VAR=value` syntax).
Running `$env:VAR = "..."` (PowerShell syntax) inside an actual `cmd.exe` window
fails outright:

```
C:\Users\klmah\Desktop\AmosNT_floq\bin>$env:CLASSPATH = ".;C:\Users\klmah\Desktop\DB2_3rdEx\kd.jar;C:\Users\klmah\Desktop\AmosNT_floq\bin\javaamos.jar"
The filename, directory name, or volume label syntax is incorrect.
```

`cmd.exe` doesn't understand `$env:` — it must use `set`. Also note: `$env:`/`set`
assignments only persist for the current shell session/process tree, so
`JAVA_HOME`/`PATH`/`CLASSPATH` need to be set again in *each new* PowerShell or
`cmd.exe` window before running `amos2.exe`.

### Working sequence (in `cmd.exe`)

With `kd.jar` (from the assignment skeleton, e.g. `DB2_3rdEx\`) and `javaamos.jar`
(from the AMOS II install's `bin\`) in different folders:

```cmd
cd "C:\Users\klmah\Desktop\AmosNT_floq\bin"
set JAVA_HOME=C:\Program Files (x86)\Java\jdk1.7.0_80
set PATH=%JAVA_HOME%\bin;%PATH%
set CLASSPATH=.;C:\Users\klmah\Desktop\DB2_3rdEx\kd.jar;C:\Users\klmah\Desktop\AmosNT_floq\bin\javaamos.jar
java -version
amos2.exe
```

This is the same shape as this repo's own `setup.cmd` (`JAVA_HOME`, `PATH`, and
`CLASSPATH` including both `kd.jar` and the AMOS `bin` directory/`javaamos.jar`) —
just with explicit absolute paths instead of the relative `../amos2` the script
assumes. Confirmed working: `amos2.exe` launches successfully with this setup.

### Getting `assignment3.cmd`/`setup.cmd` itself working (relative-path version)

Rather than hardcoding absolute paths every session, edited `DB2_3rdEx\setup.cmd`
to match the actual local layout: AMOS II installed as sibling folder `AmosNT_floq`
(not `amos2`, but still one level up from `DB2_3rdEx`, matching the script's
`../amos2` assumption structurally), and JDK 7u80 (32-bit) at
`C:\Program Files (x86)\Java\jdk1.7.0_80`.

**Gotcha: `JAVA_HOME` must include the `bin\` folder itself.** This script's own
(unusual) convention is that `JAVA_HOME` holds the JDK's `bin` directory directly,
not the JDK root — used as `%JAVA_HOME%` straight in `PATH`, with no `\bin`
appended anywhere else in the script. Setting it to just the JDK root (no trailing
`bin\`) put `PATH` one level too high, so `javac`/`java` weren't found on `PATH`:

```
set JAVA_HOME=C:\Program Files (x86)\Java\jdk1.7.0_80\
...
C:\Users\klmah\Desktop\DB2_3rdEx>javac KDTreeIndex_Stub.java
'javac' is not recognized as an internal or external command,
operable program or batch file.
```

Fix — append `bin\`:
```
set JAVA_HOME=C:\Program Files (x86)\Java\jdk1.7.0_80\bin\
```

With that fixed, the intended workflow from `DB2_3rdEx\readme.txt` works end to end:

```
C:\Users\klmah\Desktop\DB2_3rdEx>call setup.cmd
...
C:\Users\klmah\Desktop\DB2_3rdEx>call cmd setup.cmd
Microsoft Windows [Version 10.0.26200.9168]
(c) Microsoft Corporation. All rights reserved.

C:\Users\klmah\Desktop\DB2_3rdEx>javac KDTreeIndex_Stub.java

C:\Users\klmah\Desktop\DB2_3rdEx>javaamos
Release 16, v11
Connecting
Entering top loop
JavaAMOS 1>
```

Note `assignment3.cmd` itself runs `call setup.cmd` *and then* `call cmd setup.cmd`
— the second line spawns a nested `cmd.exe` and re-runs `setup.cmd` inside it
(hence the "Microsoft Windows [Version ...]" banner appearing mid-session).
Harmless — it just re-sets the same variables one shell deeper — but worth knowing
you end up one level deeper than where you started.

### Gotcha: the assignment PDF's foreign-function class name doesn't match the skeleton

With `javaamos` running, the first foreign-function `create function` statement
straight from the assignment PDF fails:

```
JavaAMOS 1> create function kdtree_make() -> Integer id as foreign
'JAVA:KDTreeIndex/kdtree_make';
Exception in thread "main" java.lang.NoClassDefFoundError: KDTreeIndex
        at callin.Connection.amosTopLoop(Native Method)
        at JavaAMOS.main(JavaAMOS.java:16)
Caused by: java.lang.ClassNotFoundException: KDTreeIndex
        ...
bindJava: Couldn't find class KDTreeIndex
.Error in function KDTREE_MAKE:
Failed to load foreign functionJAVA:KDTreeIndex/kdtree_make
```

The cause: the assignment PDF (`db2-vt13-assignment3.pdf`, e.g. Exercise 3.a and
the Mexima background section) writes the foreign-function class as
**`KDTreeIndex`** in its illustrative code listings — but the actual skeleton file
provided, [`KDTreeIndex_Stub.java`](KDTreeIndex_Stub.java), declares
`public class KDTreeIndex_Stub` (note the `_Stub` suffix). Any `'JAVA:KDTreeIndex/...'`
binding copied verbatim from the PDF will fail to find that class.

**Fix**: replace `KDTreeIndex` with `KDTreeIndex_Stub` in every foreign-function
binding copied from the PDF:

```
JavaAMOS 1> create function kdtree_make() -> Integer id as foreign 'JAVA:KDTreeIndex_Stub/kdtree_make';
#[OID 1516 "KDTREE_MAKE->INTEGER"]
0.026 s
JavaAMOS 2>
```

This is confirmed by the repo's own worked solution script
([`lab3_stub_sol-notJavaFile.java`](lab3_stub_sol-notJavaFile.java)), which
consistently uses `KDTreeIndex_Stub` throughout, never the PDF's `KDTreeIndex`.
**Rule of thumb:** every `'JAVA:KDTreeIndex/...'` string in the PDF needs `_Stub`
appended before running it.

### Decision: run `DB2_3rdEx/lab3_stub.osql`, not the PDF's inline code

Going forward, exercises are worked through by running the statements in
[`DB2_3rdEx/lab3_stub.osql`](DB2_3rdEx/lab3_stub.osql) directly, rather than
retyping code from `assignment-docs/db2-vt13-assignment3.pdf`. Checked:
`lab3_stub.osql` already uses `KDTreeIndex_Stub` correctly in every
`create function ... as foreign` statement (the only `KDTreeIndex` without `_Stub`
left anywhere in that file is a stray comment under Exercise 4.a — the actual
executable statement right below it is correct). The PDF is still useful for
reading what each exercise/TODO is asking for, just not for copying code from.

## Exercise 1 — schema, population, and `getSample` scaling

Working through [`DB2_3rdEx/lab3_stub.osql`](DB2_3rdEx/lab3_stub.osql) (per the
decision above), from the top through `/*TODO 1.c How will it scale? Why?*/`.
Full transcript in `run-log.log`; analysis below.

### Schema and data load

```
JavaAMOS 1> create type WineSample;
#[OID 1513 "WINESAMPLE"]

JavaAMOS 2> create function wsId(WineSample ws) -> Number id as stored;
#[OID 1515 "WINESAMPLE.WSID->NUMBER"]

JavaAMOS 3> create function features(WineSample ws) -> Vector of Number f as stored;
#[OID 1518 "WINESAMPLE.FEATURES->VECTOR-NUMBER"]
```

`wsId` and `features` are stored functions on `WineSample`. As usual, AMOS
automatically adds a default **unique hash index on position 0** (the argument,
`ws`) for each — since a `WineSample` object has exactly one `wsId`/`features`
value, indexing by the object itself is inherently unique.

```
JavaAMOS 5> create function addwinesample(...) -> Boolean as begin ... end;
JavaAMOS 6> addwinesample(cast(read_ntuples('winequalitysample.csv') as Vector of Number), :csvpos);
JavaAMOS 7> count(select s from WineSample s);
2939
```

Confirms the dataset loaded in full — matches the expected 2939 wine samples.

### Before indexing: `getSample` does a full scan

```
JavaAMOS 8> create function getSample(Number wsId) -> Winesample ws
  as select ws where wsId(ws) = wsId;

JavaAMOS 9> getSample(37);
#[OID 1558]

JavaAMOS 9> pc("getSample");
Execution plan:
(NUMBER.GETSAMPLE->WINESAMPLE WSID- WS+) <-
(HASH-FULL-SCAN #[OID 1515 "WINESAMPLE.WSID->NUMBER"] WS+ WSID-)
```

**Why this is a full scan, not a get:** `getSample`'s call pattern binds `wsId`
(the `Number`) and asks for `ws` (the `WineSample`) — the *reverse* of `wsId`'s own
declared direction. The only index that exists so far is on position 0 (`ws`), not
position 1 (`id`) — so looking something up *by* `id` has nothing to seek with.
AMOS falls back to walking every stored `(ws, id)` pair in `wsId`'s hash table and
checking each one's `id` against `37` — the same mechanism as the reverse-lookup
examples in [`amos-query-optimization/tutorial-index-execution-plans.md`](../amos-query-optimization/tutorial-index-execution-plans.md).

**TODO 1.b — how will it scale? Why?** It does **not** scale: every call is
`O(n)` in the number of `WineSample` rows (2939 here), regardless of which `wsId`
is requested, because the full hash table has to be walked and checked entry by
entry. Ten repeated calls (`getSample(37)` × 10) all land in a similar ~0.014–0.03s
range in this run — with only 2939 rows the absolute cost is small and doesn't
visibly trend, but the *mechanism* is still a full scan; the scaling problem would
show up as the dataset grows, not necessarily as a visible slowdown at this size.

### Adding an index on `wsId`'s result

```
JavaAMOS 9> create_index("wsId", "id", "hash", "unique");
{NIL,NIL}

JavaAMOS 10> indexes(#"wsId");
{#[OID 1516 "P_WINESAMPLE.WSID->NUMBER"],0,"hash","unique"}
{#[OID 1516 "P_WINESAMPLE.WSID->NUMBER"],1,"hash","unique"}
```

Now `wsId` carries **two independent hash indexes**, one per position — same
pattern as the `dept`/`age` examples in the tutorial: position 0 (`ws`) has the
automatic index from before; position 1 (`id`) has the new one just created,
declared `"unique"` since `wsId` values are meant to be one-per-sample.

```
JavaAMOS 10> reoptimize("getSample");
#[OID 4466 "NUMBER.GETSAMPLE->WINESAMPLE"]

JavaAMOS 11> getSample(37);  /* × 10 */
#[OID 1558]
```

**TODO 1.c — how will it scale? Why?** With a unique index now present on `id`
(position 1) — the side `getSample` binds — the optimizer should be able to
rewrite the reverse lookup as a direct `HASH-INDEX-GET` instead of a
`HASH-FULL-SCAN`: `O(1)`-ish per call instead of `O(n)`, regardless of table size.
**Not yet re-confirmed with `pc("getSample")` after `reoptimize`** in this run —
the transcript moves straight to timing the repeated calls without re-inspecting
the plan. Per this project's own convention (verify before writing something as
fact), the next step is to run `pc("getSample")` again post-`reoptimize` and check
it actually reports `HASH-INDEX-GET` with pattern `WSID- WS+`, rather than assuming
it from the mechanism alone.

On timing: the ten repeated `getSample(37)` calls after indexing land in roughly
the same ~0.015–0.029s range as before indexing — no clearly visible speedup at
this small scale (2939 rows), consistent with the full-scan cost already being
cheap in absolute terms here. The expected benefit of the index is architectural
(algorithmic complexity), not necessarily a visible wall-clock difference on a
dataset this small.

## Exercise 2 — naive proximity search with `euclid`

Continuing in [`DB2_3rdEx/lab3_stub.osql`](DB2_3rdEx/lab3_stub.osql), from
`closeWineSamples`'s definition through `/**TODO 2.b Give your comments on speed.
Why this result?*/`.

```
JavaAMOS 17> create function closeWineSamples(WineSample ws, Number distance)
       -> Bag of WineSample as select closestws from WineSample closestws
       where euclid(features(ws),features(closestws)) <= distance;
#[OID 4468 "WINESAMPLE.NUMBER.CLOSEWINESAMPLES->WINESAMPLE"]

JavaAMOS 18> set :ws = getSample(37);

JavaAMOS 19> closeWineSamples(:ws, 3);
#[OID 1558]
#[OID 3158]
0.036 s
```

`closeWineSamples` selects every `closestws` in `WineSample` whose feature vector
is within `distance` (Euclidean) of `ws`'s. Ten repeated calls with the same
arguments land in the ~0.036–0.054s range (0.036, 0.039, 0.039, 0.045, 0.049,
0.054, 0.045, 0.048, 0.038, 0.052, 0.045) — noticeably slower than `getSample`'s
~0.015–0.03s from Exercise 1 (roughly 1.5–2× on this small dataset), and
fluctuating rather than trending in either direction across the ten runs (no
warm-up speedup visible).

**TODO 2.b — how will it scale? Why? Comment on speed.** No index exists on
`features`, and `euclid(...)` is a computed distance, not a stored/indexable
value — so this query has to (a) look up `ws`'s own features (cheap, via the
automatic index on `features`'s argument), then (b) **fully scan every
`WineSample`** computing `euclid(features(ws), features(closestws))` for each one
and checking `<= distance`. That's `O(n)` distance computations per call — worse
than Exercise 1's full scan, since each of the `n` rows here does real
floating-point vector-distance work (11-dimensional feature vectors), not just a
key comparison, which plausibly explains the ~1.5–2× slower timing observed
compared to `getSample`'s full scan. **This does not scale**: cost grows linearly
with the number of wine samples, with no way to prune rows early — every row must
have its distance computed and checked, regardless of how selective `distance` is.

**Confirmed with `pc("closeWineSamples")`:**

```
Execution plan:
(WINESAMPLE.NUMBER.CLOSEWINESAMPLES->WINESAMPLE WS- DISTANCE- CLOSESTWS+) <-
(NESTED-LOOP-JOIN
   (HASH-INDEX-GET #[OID 1518 "WINESAMPLE.FEATURES->VECTOR-NUMBER"] WS-
      _V2+)
   (HASH-FULL-SCAN #[OID 1518 "WINESAMPLE.FEATURES->VECTOR-NUMBER"] CLOSESTWS+
      _V3+)
   (CALL #extpred "EUCLIDBBF"# #[OID 819 "VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER"]
      _V2- _V3- _V4+)
   (CALL #extpred "LE--"# #[OID 200 "OBJECT.OBJECT.<=->BOOLEAN"] _V4- DISTANCE-))
```

This matches the predicted shape exactly, and confirms each piece of the
reasoning above:

- **`HASH-INDEX-GET` on `features`, `WS- _V2+`** — a single, fast lookup of `ws`'s
  own feature vector (`_V2`), since `ws` is bound and `features`'s automatic index
  on its argument makes this a direct get. Cheap, `O(1)`-ish, done once.
- **`HASH-FULL-SCAN` on `features`, `CLOSESTWS+ _V3+`** — this is the expensive
  part: both `closestws` and its feature vector `_V3` are unbound, so every stored
  `WineSample` gets walked to enumerate them. This is the `O(n)` term.
- **`CALL EUCLIDBBF`** — for every row produced by the full scan, computes
  `euclid(_V2, _V3)` — the actual per-row floating-point vector-distance work that
  (per the timing comparison above) plausibly explains why this is slower than
  Exercise 1's key-comparison-only full scan.
- **`CALL LE--`** (`<=`) — filters each computed distance against `distance`,
  *after* it's already been computed — i.e. the filter can't prune rows before
  paying for the `euclid` call; every row pays the full distance-computation cost
  regardless of whether it ends up matching.

This is exactly the motivation for Exercise 3's KD-tree index: the `NESTED-LOOP-JOIN`
+ `HASH-FULL-SCAN` + per-row `euclid` pattern is fundamentally `O(n)` per query, and
no combination of built-in hash/mbtree indexes on `features` can change that, since
none of them can index on *distance-to-an-arbitrary-point* — which is precisely
what a KD-tree is for.

## Session transcript

```
AmosQL 1>  create function winequalitysamples(Number sp)-> Vector of Number wq as
stored;
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.006 s

AmosQL 2>  create_index("winequalitysamples", "wq", "MBTREE", "multiple");
{NIL,NIL}
0.018 s

AmosQL 3>  indexes(#'winequalitysamples');
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],0,"hash","unique"}
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],1,"mbtree","multiple"}
0.043 s

AmosQL 3> drop_index('winequalitysamples', 'sp');
0
0.015 s

AmosQL 4> drop_index('winequalitysamples', 'wq');
Trying to remove last index on NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER
0.003 s

AmosQL 4> indexes(#'winequalitysamples');
{#[OID 1515 "P_NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"],1,"mbtree","multiple"}
0.028 s

AmosQL 4> pc(#'winequalitysamples');
----------------------------
winequalitysamples(Number)->Vector of Number

Execution plan:
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.025 s
AmosQL 4>
```

## What happened, step by step

1. `create function winequalitysamples(...) as stored` — defines a stored function
   `sp -> wq`. AMOS automatically adds a default unique **hash** index on the first
   argument (`sp`), since stored functions need a key to look up by.
2. `create_index(..., "wq", "MBTREE", "multiple")` — adds a second, non-unique **MBTREE**
   index (a metric/M-tree, suited to vector similarity search) on `wq`. Now two indexes
   exist: `hash` on `sp` (position 0), `mbtree` on `wq` (position 1).
3. `indexes(#'winequalitysamples')` confirms both.
4. `drop_index('winequalitysamples', 'sp')` — removes the hash index on `sp`. Succeeds
   because `wq`'s mbtree index remains, so the function still has at least one index.
5. `drop_index('winequalitysamples', 'wq')` — refused ("Trying to remove last index"):
   AMOS always requires at least one index on a stored function, and `wq`'s mbtree is now
   the only one left.
6. `indexes(...)` confirms only the mbtree index on `wq` (position 1) survives.
7. `pc(#'winequalitysamples')` prints the execution plan — discussed below.

## Explaining the execution plan

```
Execution plan:
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
#[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
0.025 s
```

**Line 1 — the function call header**
```
(NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER SP- WQ+) <-
```
Names the function being planned: `winequalitysamples(Number)->Vector of Number`, called
with `sp` bound (`-`) as input and `wq` unbound (`+`) as the output being produced. The
`<-` means "is computed by the plan below."

**Lines 2-3 — the physical operator**
```
(MBTREE-FULL-SCAN #[OID 1514 "NUMBER.WINEQUALITYSAMPLES->VECTOR-NUMBER"]
   SP- WQ+)
```
This is the single physical algebra operator executing the call. Per the general pattern
`<INDEX>-FULL-SCAN`: **iterate over the entire MBTREE index, checking every entry**, rather
than jumping directly to the entries matching `sp`. It takes `sp` bound and emits `wq` for
each match found by scanning.

**Why FULL-SCAN and not INDEX-GET/INDEX-SCAN**, even though an index exists: the hash index
on `sp` was dropped, leaving only the mbtree index on `wq`. An MBTREE is built over `wq`
values (for vector-similarity lookups), not over `sp` — it offers no efficient way to seek
"give me the row where `sp` = X." So even though *an* index exists, it isn't usable for
this query's bound/unbound pattern, and the engine falls back to walking the whole tree and
checking each entry's `sp` value one by one — i.e. a full scan.

**Bottom line:** after dropping the index on `sp`, `winequalitysamples` no longer scales —
every call does O(n) work regardless of table size, because the only remaining index
(mbtree on `wq`) isn't usable for looking up by `sp`. Re-adding a hash/unique index on `sp`
would be expected to restore a `HASH-INDEX-GET` plan, which scales.
