@echo off

echo --------------------------------------------------
echo starting  standalone Amos web server .....
echo --------------------------------------------------

pushd "%AMOS_HOME%\"embeddings\wsmos\AmosWebServer
call setup
call compile
call WSMOSServer

popd