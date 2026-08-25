# Assignment 3 — Extensible Database Indexing

Uppsala University, Department of Information Technology
Database Design II (1DL400) — Thanh Truong

> **Environment note:** the `amos2.zip` distribution described in the assignment
> instructions could not be located. Instead, an **`AmosNT_floq`** build (which
> includes source code) was used, backed up at
> `/Volumes/WD4TB/WB-backup-2012-10/_check/_softwares-fixed/amos-backup/AmosNT_floq`
> on a 4TB external disk drive. The 32-bit JDK used
> (`jdk-7u80-windows-i586.exe`, see the known issue below) is also archived there,
> at
> `/Volumes/WD4TB/WB-backup-2012-10/_check/_softwares-fixed/amos-backup/lab3-java-32-bit/jdk-7u80-windows-i586.exe`,
> for future use. This was run on **Windows 11**, itself running inside a
> **VMware Fusion** VM. The assignment folder
> (`uu-db2-assign3-extensible-index`) was copied to the Windows desktop (as
> `DB2_3rdEx`) for local work; see [`lab-notes.md`](lab-notes.md) for the full
> environment setup and troubleshooting log.

## 1. Overview

This assignment gives hands-on experience with **extensible indexing** in the AMOS II
object-relational DBMS. B-tree/hash indexes scale range and equality queries on scalar
attributes, but many applications need scalable search on other criteria — e.g. finding
vectors of numbers that are close to a given vector. AMOS II has no built-in index for this,
so the assignment has you add one.

The task is to:

1. Write a **KD-tree**-based external index manager for AMOS II, using a pre-compiled
   Java KD-tree package ([`kd.jar`](kd.jar), by Simon D. Levy).
2. Wire it into AMOS II as **foreign functions** (Java functions callable from AmosQL).
3. Register it as a first-class **index type** via AMOS II's **Mexima** (Meta External Index
   Manager) mechanism, so that the query optimizer *transparently* rewrites Euclidean
   proximity queries to use the KD-tree index — no changes to application queries required.
4. Compare its behavior and performance against a full scan, a manually-invoked KD-tree
   search, and the built-in **X-tree** index type, using AMOS II's execution-plan inspector
   (`pc(...)`).

Dataset: `winequalitysample.csv`, 2939 wine samples, each with an id and an 11-dimensional
feature vector.

## 2. Background concepts

- **Extensible indexing**: AMOS II ships with Linear Hashing, B-tree, and X-tree indexes,
  created/dropped on a stored function's parameter via
  `create_index(function, argname, indextype, uniqueness)` /
  `drop_index(function, argname)`. At least one index must remain on a stored function.
- **Physical algebra / execution plans**: `pc("funcname")` prints a function's execution
  plan in AMOS II's internal physical algebra. Key operators:
  - `<INDEX>-FULL-SCAN` — iterates the whole index; does not scale.
  - `<INDEX>-INDEX-SCAN` — looks up all matches for a key in a "multiple" index; scales as
    long as multiplicity stays low.
  - `<INDEX>-INDEX-GET` — direct single-tuple lookup; scales if the index is sound.
  - `CALL` — invokes a foreign function (e.g. a custom index search).

  Bound plan variables are marked `-`, unbound (output) variables `+`.
- **Foreign functions**: AmosQL functions can be implemented in Java (or C/Lisp) and bound
  via `create function ... as foreign 'JAVA:<Class>/<method>'`. A Java implementation takes
  `(CallContext cxt, Tuple tpl)`; it reads arguments positionally from `tpl` with typed
  getters (`getIntElem`, `getDoubleElem`, `getOidElem`, `getSeqElem`, ...), writes results
  with `tpl.setElem(pos, value)`, and returns rows by calling `cxt.emit(tpl)` (once per
  output row — called repeatedly for a bag/multi-row result).
- **Mexima**: the generic mechanism that lets AMOS II delegate index management to an
  external index manager (Exima) implemented in Java or C. A new index type is registered
  with `register_exindextype(indextype, manualsaver)`, then a fixed set of foreign
  functions is defined to implement it:
  - `<type>_make() -> Integer` — creates a new index instance, returns its id.
  - `<type>_put(Integer id, Object key, Object val) -> Object` — stores `val` under `key`.
  - `<type>_get(Integer id, Object key) -> Object` — retrieves the value for `key`.
  - `<type>_delete(Integer id, Object key) -> Object` — removes `key`.
  - `<type>_clear(Integer id) -> Object` — drops the whole index instance.
  - `<type>_save` / `<type>_load` — optional, only needed if `manualsaver` is `true`
    (not used in this assignment; AMOS II handles persistence automatically).
  - `<type>_mapper(Integer id) -> Bag of Object` — optional, iterates all key/value pairs
    (not required — the KD-tree package does not support full iteration).

  Once implemented, a Lisp **index rewrite rule** (see [`kdtree.lsp`](kdtree.lsp)) tells the
  optimizer to rewrite calls to the built-in `euclid(Vector, Vector) -> Number` distance
  function into a call to the KD-tree's proximity-search foreign function whenever the
  relevant column has a KD-tree index — this is what makes the indexing *transparent*.
- **KD-tree**: a main-memory data structure generalizing binary search trees to
  multi-dimensional keys, used here to index the wine samples' feature vectors for fast
  proximity search. The implementation is supplied pre-compiled in `kd.jar`
  (API: http://home.wlu.edu/~levys/software/kd/); only the AMOS II integration layer
  (`KDTreeIndex_Stub.java`) needs to be written.

## 3. Repository contents

| File | Purpose |
|---|---|
| [`kd.jar`](kd.jar) | Pre-compiled KD-tree implementation (Simon Levy). Do not modify. |
| [`kdtree.lsp`](kdtree.lsp) | Lisp rewrite rule mapping `euclid(...)` calls to `kdtreeProximitySearch` for transparent indexing. Must be left intact. |
| [`lab3_stub-empty.osql`](lab3_stub-empty.osql) | Blank AmosQL script with `TODO` markers — the starting point for the exercises below. |
| [`lab3_stub_sol-notJavaFile.java`](lab3_stub_sol-notJavaFile.java) | Worked AmosQL solution script with execution plans/timings recorded as comments (despite the `.java` name, this is AmosQL, not Java). |
| [`KDTreeIndex_Stub.java`](KDTreeIndex_Stub.java) | Java skeleton/implementation of the foreign functions backing the KD-tree index manager. |
| [`winequalitysample.csv`](winequalitysample.csv) | Dataset: 2939 wine samples. Do not modify — the validation script depends on it. |
| [`setup.cmd`](setup.cmd) / [`assignment3.cmd`](assignment3.cmd) | Windows scripts that set `JAVA_HOME`/`PATH`/`CLASSPATH` (pointing at a sibling `../amos2` install) and launch the environment. |
| [`assignment-docs/`](assignment-docs) | Original assignment PDFs/DOCX. |

AMOS II itself (`amos2.zip`) is **not** included — it must be downloaded separately and
unzipped as a sibling directory (`../amos2`), per the original course instructions.

## 4. Setup & running

```
# Windows: set JAVA_HOME/PATH/CLASSPATH (expects AMOS II unzipped at ../amos2)
setup.cmd

# Compile the Java foreign functions
javac KDTreeIndex_Stub.java

# Launch the AMOS II Java interpreter
javaamos
```

At the `Javaamos N>` prompt, paste and run statements from the OSQL script one at a time —
the script is meant to be worked through interactively so execution plans (`pc(...)`) and
timings can be compared at each step, not executed as a single batch.

### Known issue: `amos2.exe` requires a 32-bit JDK

`amos2.exe` (the native launcher inside `amos2.zip`'s `bin/` folder) is a **32-bit
(x86)** executable. Since it loads the JVM in-process (via JNI), it can only load a
**32-bit `jvm.dll`** — pointing `JAVA_HOME` at a modern 64-bit JDK will fail (e.g.
"not a valid Win32 application," or a JNI/`jvm.dll` load error).

To confirm an `amos2.exe`'s architecture yourself, check the `Machine` field in its
PE header — from PowerShell, no extra tools required:

```powershell
$path = "path\to\amos2.exe"
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

`14C` = 32-bit (x86) — the case observed for this assignment's `amos2.exe`. `8664`
would mean 64-bit (x64).

**Fix:** install a **32-bit JDK** and point `JAVA_HOME` at it in `setup.cmd`. Oracle
stopped publishing 32-bit JDK builds after Java 8, so target a 32-bit JDK build
(satisfies the assignment's "1.6 or higher" requirement) — free 32-bit Windows
builds are available from Eclipse Adoptium (Temurin) or Azul Zulu.

For this repo, **`jdk-7u80-windows-i586.exe`** (32-bit/x86 build of JDK 7u80) was
downloaded from
https://www.oracle.com/java/technologies/javase/javase7-archive-downloads.html
and used to run `amos2.exe` successfully.

**Gotcha when editing `setup.cmd`:** this script's convention is that `JAVA_HOME`
holds the JDK's **`bin`** directory directly (it's used bare in `PATH`, with no
`\bin` appended elsewhere) — e.g. the original assignment's own
`JAVA_HOME=...\jdk1.7.0_40\bin\`. Setting it to just the JDK root (no trailing
`bin\`) leaves `javac`/`java` off `PATH`:
```
'javac' is not recognized as an internal or external command, operable program or batch file.
```
Fix: make sure `JAVA_HOME` ends in `\bin\`, e.g.
`set JAVA_HOME=C:\Program Files (x86)\Java\jdk1.7.0_80\bin\`.

With a 32-bit JDK installed and `setup.cmd`'s `JAVA_HOME`/paths pointed at the
correct local install (see [`lab-notes.md`](lab-notes.md) for the exact working
session), the full documented workflow succeeds end to end:
```
call setup.cmd
javac KDTreeIndex_Stub.java
javaamos
```
```
Release 16, v11
Connecting
Entering top loop
JavaAMOS 1>
```

### Known issue: the assignment PDF's foreign-function class name doesn't match the skeleton

The assignment PDF's illustrative code listings (e.g. Exercise 3.a) write the
foreign-function class as **`KDTreeIndex`**, e.g.:
```
create function kdtree_make() -> Integer id as foreign 'JAVA:KDTreeIndex/kdtree_make';
```
But the actual skeleton file provided, [`KDTreeIndex_Stub.java`](KDTreeIndex_Stub.java),
declares `public class KDTreeIndex_Stub` — note the `_Stub` suffix. Running the
PDF's version verbatim fails:
```
Exception in thread "main" java.lang.NoClassDefFoundError: KDTreeIndex
...
bindJava: Couldn't find class KDTreeIndex
```

**Fix:** append `_Stub` to the class name in every foreign-function binding copied
from the PDF:
```
create function kdtree_make() -> Integer id as foreign 'JAVA:KDTreeIndex_Stub/kdtree_make';
```
This matches what [`lab3_stub_sol-notJavaFile.java`](lab3_stub_sol-notJavaFile.java)
uses throughout — `KDTreeIndex_Stub`, never the PDF's `KDTreeIndex`.

### Source of truth: follow `DB2_3rdEx/lab3_stub.osql`, not the PDF

Given the mismatch above, exercises going forward are worked through using
[`DB2_3rdEx/lab3_stub.osql`](DB2_3rdEx/lab3_stub.osql) as the actual script to run
— not by retyping statements from `assignment-docs/db2-vt13-assignment3.pdf`.
`lab3_stub.osql` already uses the correct `KDTreeIndex_Stub` class name in its
`create function ... as foreign` statements (checked: all of them do, except one
stray comment under Exercise 4.a that still says `KDTreeIndex` — the actual
executable statement right below it is correct). The PDF remains useful for the
exercise *descriptions*/what each `TODO` is asking for, but its inline code
snippets should not be copy-pasted directly.

## 5. Exercises

The database schema is defined first:

```
create type WineSample;
create function wsId(WineSample ws) -> Number id as stored;
create function features(WineSample ws) -> Vector of Number f as stored;
```

1. **Baseline lookup.** Implement `getSample(Number wsId) -> WineSample` (a derived
   function selecting by `wsId`). Inspect its execution plan with `pc("getSample")` and
   discuss scalability, then add a unique hash index on `wsId` and compare the plan/speed
   before and after.
2. **Naive proximity search.** Implement `closeWineSamples(WineSample ws, Number distance)
   -> Bag of WineSample` using the built-in `euclid` function to filter by distance.
   Inspect its plan and discuss why it does not scale (full scan + per-row distance calc).
3. **Manual KD-tree usage.**
   - Implement the foreign function `kdtree_make() -> Integer` (in
     `KDTreeIndex_Stub.java`), which allocates a new KD-tree and returns its id.
   - Store its id in a stored function `winesampleIndex()`.
   - Implement the foreign function `kdtree_put(Integer id, Object key, Object val) ->
     Object`, which inserts a feature vector/object pair into the KD-tree.
   - Define `addWineSampleIndex(WineSample ws, Vector of Number fv) -> WineSample` calling
     `kdtree_put`, and populate the index with `for each WineSample ws
     addWineSampleIndex(ws, features(ws));`.
4. **Manual KD-tree proximity search.**
   - Implement the foreign function `kdtreeProximitySearch(Integer id, Vector of Number f,
     Number distance) -> Bag of Object`, returning objects in the KD-tree within `distance`
     of `f`.
   - Define `closeWineSamples2(WineSample ws, Number dist) -> Bag of WineSample` calling it
     directly.
5. **Compare.** Investigate speed and execution plans of `closeWineSamples` (naive) vs.
   `closeWineSamples2` (manual KD-tree call) and explain the difference.
6. **Transparent indexing.**
   - Register a new index type: `register_exindextype('KDTREE', FALSE)`.
   - Implement/bind the remaining Mexima foreign functions: `kdtree_get`, `kdtree_delete`,
     `kdtree_clear` (`kdtree_make`/`kdtree_put` already exist from Exercise 3).
   - Load the rewrite rule with `load_lisp('kdtree.lsp')`.
   - Create a KDTREE index on the `f` parameter of `features` via `create_index("features",
     "f", "KDTREE", "multiple")`, then `recompile`/`reoptimize` `closeWineSamples` and
     confirm via `pc(...)` that its plan now transparently uses `kdtreeProximitySearch`
     — with no change to the `closeWineSamples` query itself.
7. **X-tree comparison.** Replace the KDTREE index on `features.f` with the built-in XTREE
   index type (`drop_index` + `create_index(..., "XTREE", "multiple")`), reoptimize, and
   compare the resulting execution plan and performance against the KD-tree version.
8. **Exact-match search.** Implement `featuredWineSamples(Vector of Number fv) -> Bag of
   WineSample`, selecting samples with an exact feature-vector match, and discuss its
   execution plan and scalability.

## 6. Hand-in & validation

Each group submits a single compressed archive containing:

- `lab3_stub.osql` (the completed exercise script, with comments answering the "how will
  it scale / why" questions for each exercise — useful if the validation script doesn't
  cover a case),
- `kdtree.lsp` (unmodified),
- `KDTreeIndex_Stub.java`,
- `group.txt` (group number, member names and emails).

Grading: an automated validation script runs first, followed by manual review of the
written answers and the AmosQL/Java code.

## 7. References

1. S. Flodin et al., *Amos II Release 13 Version 1*, Feb 2011 —
   http://user.it.uu.se/~udbl/amos/doc/amos_users_guide.html
2. R. Elmasri, S. B. Navathe, *Fundamentals of Database Systems*, 6th ed., Addison-Wesley,
   2010 (chapters 20–22).
3. Simon D. Levy, *KD-Tree Implementation in Java and C#*, 2011 —
   http://home.wlu.edu/~levys/software/kd/
4. T. Padrón-McCarthy, T. Risch, *Databasteknik*, 2005 (chapter 16).
5. D. Elin, T. Risch, *Amos II Java Interfaces*, Technical report, 2000 —
   http://user.it.uu.se/~torer/publ/javaapi.pdf
