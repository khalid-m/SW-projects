set BINARIES=(amos2, amos2_d, pyamos2, pyamos2_d)
set EXTENSIONS=(pyd, pdb, exe, lib)

for %%B in %BINARIES% do (
    for %%E in %EXTENSIONS% do (
        if exist bin\%%B.%%E del bin\%%B.%%E))

REM Compile Amos2
pushd ..\..\..\system\MVC
call compile
popd

REM Compile python callout
pushd MVC
msdev amos2.dsw /rebuild /make "amos2 - Win32 Release With Debug"
msdev pyamos2.dsw /rebuild /make "pyamos2 - Win32 Release With Debug"
popd