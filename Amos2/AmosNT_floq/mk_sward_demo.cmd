set releasing=1
echo Making image...
pushd bin
call install
amos2 amos2.dmp mkrunnable.osql
del amos2.dmp
ren amosr.dmp amos2.dmp
popd

pushd sward
call compile
call mkdmp
popd

echo Removing old sward.zip ...
del sward.zip

echo Building new sward.zip ...
zip sward bin\SWARD.dll bin\sward.jar bin\sward.dmp 

pushd sward

mkdir demo

copy sward.cmd demo\sward.cmd
copy setup.cmd demo\setup.cmd

copy regress\egov.sql demo\egov.sql
copy regress\egovdb.cmd demo\egovdb.cmd
copy readme.txt demo\readme.txt

zip ..\sward demo\sward.cmd demo\egov.sql demo\egovdb.cmd demo\readme.txt  

pushd demo

del /Q *.*

popd

rmdir demo

popd