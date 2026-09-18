@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

java -classpath "%SWARD_ROOT%\bin\sward.jar;%CLASSPATH%" SWARD "%SWARD_ROOT%\bin\sward.dmp" -O %SWARD_ROOT%/SWARD/regress/egov.amosql -o "quit;"

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END
