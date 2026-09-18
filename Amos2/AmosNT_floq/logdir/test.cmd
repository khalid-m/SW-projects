call compile.cmd
call mkdmp.cmd
pushd ..\validate
call compile
call mkdmp
call mkdll
popd
pushd hlund
call mkdmp.cmd
call run.cmd -O regress.osql
popd
pushd tview
call mkdmp.cmd
call test.cmd
popd
