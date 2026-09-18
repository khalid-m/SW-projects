@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

rem OLD PARSER TEST DISABLED:
rem java -classpath "%SWARD_ROOT%\bin\sward.jar;%CLASSPATH%" SWARD "%SWARD_ROOT%\bin\sward.dmp" %SWARD_ROOT%/SWARD/regress/sparql.amosql -o "quit;"

rem THIS IS IN THE KERNEL TEST ALSO:
pushd %AMOS_HOME%\SQoND\test
java -classpath "%SWARD_ROOT%\bin\sward.jar;%CLASSPATH%" SWARD "%SWARD_ROOT%\bin\sward.dmp" regress-string-based.lsp -o "quit;"
popd

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END
