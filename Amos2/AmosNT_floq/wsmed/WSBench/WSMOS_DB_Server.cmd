:Installing the WSMOS database server

pushd %AMOS_HOME%\embeddings\WSMOS

call setup.cmd

call compile.cmd

call mkdmp.cmd

start amos2 -n

startDatabaseWB.cmd

popd
