@echo off
pushd ..\..\validate
call compile
call mkdmp
call mkdll
popd

pushd ..\
call compile
call mkdmp
popd

call mkdmp
run -O regress.osql
