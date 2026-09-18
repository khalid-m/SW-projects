@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

pushd %SWARD_ROOT%\SWARD\src\java
call jjtree rdql2amos.jjt
call javacc rdql2amos.jj
popd

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END
