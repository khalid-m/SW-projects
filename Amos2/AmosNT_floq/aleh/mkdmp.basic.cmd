@echo off

IF NOT EXIST %AMOS_HOME%\wrappers\ROOTWrap\ROOTWrap.exe GOTO failed
IF NOT EXIST %AMOS_HOME%\wrappers\ROOTWrap\rootwrap.dmp GOTO failed

pushd osql
%AMOS_HOME%\wrappers\ROOTWrap\ROOTWrap.exe rootwrap.dmp master.basic.osql -o "quit;"
popd
goto end

:failed
echo ***************************************
echo * Failed: ROOT wrapper doesn't exist
echo ***************************************

:end