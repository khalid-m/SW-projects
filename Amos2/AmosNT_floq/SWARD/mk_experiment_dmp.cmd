@echo off 	

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

java -classpath "%SWARD_ROOT%\bin\sward.jar;%CLASSPATH%" SWARD %SWARD_ROOT%\bin\amos2.dmp %SWARD_ROOT%/SWARD/src/amosql/mk_experiment_dmp.amosql

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END