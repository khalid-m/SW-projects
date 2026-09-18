:Deploying the WSMOS stand-alone web server

pushd %AMOS_HOME%\embeddings\wsmos\AmosWebServer

call setup.cmd

call compile.cmd

call WSMOSServer.cmd

popd