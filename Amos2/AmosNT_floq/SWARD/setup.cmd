@echo off

IF "%SWARD_ROOT%"=="" GOTO SETENV

GOTO END

:SETENV
pushd ..\
set SWARD_ROOT=%cd%
set PATH=%SWARD_ROOT%\bin;%PATH%
popd

:END
