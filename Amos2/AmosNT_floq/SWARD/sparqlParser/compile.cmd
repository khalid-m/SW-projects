@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

pushd %SWARD_ROOT%\SWARD\src\C
call bison-flex.cmd
popd
msdev sparqlParser.dsw /make

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END