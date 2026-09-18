start amos2 -n
pushd %AMOS_HOME%\embeddings\wsmos\
call setup.cmd
call startDatabase.cmd
pushd %AMOS_HOME%\embeddings\wsmos\AmosWebServer\
call setup.cmd
call WSMOSServer.cmd
popd
popd
start amos2 -c "hi" -O C:\AmosNT\wsmed\src\amosql\auxuszip.amosql