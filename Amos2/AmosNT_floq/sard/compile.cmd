pushd ..\wrappers\RDF
call compile
popd
IF "%SWARD_ROOT%"=="" GOTO SETENV

GOTO END

:SETENV
pushd ..\
set SWARD_ROOT=%cd%
set PATH=%SWARD_ROOT%\bin;%PATH%
popd

:END
pushd ..\SWARD
call compile
popd

