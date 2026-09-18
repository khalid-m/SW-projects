call killall
pushd ..\validate
call install.cmd
popd
pushd wrappers
msdev wrappers.dsw /make
popd
call mkdmp.cmd
