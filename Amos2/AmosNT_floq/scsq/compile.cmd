if exist ..\bin\scsq.exe del ..\bin\scsq.exe
if exist ..\bin\scsq.pdb del ..\bin\scsq.pdb
if exist ..\bin\scsqlib.lib del ..\bin\scsqlib.lib
pushd ..\system\MVC
call compile
popd
pushd MVC
call compilescsq
popd
