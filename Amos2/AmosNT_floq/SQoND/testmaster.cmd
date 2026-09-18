call compile.cmd
call mkdmp.cmd
cd test
call test.cmd
popd 
pushd ..\ssdm
call test.cmd
