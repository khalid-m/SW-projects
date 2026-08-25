# Run Log — Assignment 3 (Extensible Database Indexing)

Environment: **Amos II Release 16, v11** (assignment doc examples were written against an
older release, but the behavior matches).

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
