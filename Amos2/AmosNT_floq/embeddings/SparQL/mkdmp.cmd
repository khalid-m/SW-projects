@echo off
pushd ..\..\wrappers\CRDF
call compile.cmd
call mkdmp.cmd
echo CRDF wrapper compiled!
popd
.\exe\SparQL.exe ..\..\wrappers\CRDF\CRDFAmos.dmp "mkdmp.amosql"

