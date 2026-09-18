@echo off

echo --------------------------------------------------
echo setup and compile  wsmos .....
echo --------------------------------------------------

pushd "%AMOS_HOME%\"embeddings\wsmos
call setup
call compile

echo --------------------------------------------------
echo mkdmp .....
echo --------------------------------------------------

IF EXIST wsmos.dmp del wsmos.dmp /q
call mkdmp

popd

echo --------------------------------------------------
echo adding courses .....
echo --------------------------------------------------

amos2 %AMOS_HOME%\embeddings\wsmos\WEB-INF\wsmos.dmp osql/CMWS.osql