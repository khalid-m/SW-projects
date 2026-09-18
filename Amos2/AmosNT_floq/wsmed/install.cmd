call setup.cmd
call compile.cmd
call mkdmp.cmd
pushd ..\embeddings\wsmos
call setup.cmd
call compile.cmd
call mkdmp.cmd
pushd AmosWebServer
call setup.cmd
call compile.cmd
popd
popd
