@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

pushd %SWARD_ROOT%\SWARD\src\C
call bison-flex.cmd
popd
msdev sward.dsw /make

pushd %SWARD_ROOT%\SWARD\src\java
javac -classpath "%SWARD_ROOT%\bin\javaamos.jar;%CLASSPATH%" -d %SWARD_ROOT%\SWARD\classes SparQL.java
popd

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END