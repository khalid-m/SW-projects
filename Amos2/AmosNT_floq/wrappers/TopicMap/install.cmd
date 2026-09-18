pushd ..\..\SWARD
call setup.cmd
call compile.cmd
call mkdmp.cmd
popd
call compile.cmd
call mkdmp.cmd
