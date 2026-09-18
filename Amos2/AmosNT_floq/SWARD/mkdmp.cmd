@echo off 	

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

java -classpath "%SWARD_ROOT%\bin\sward.jar;%CLASSPATH%" SWARD %SWARD_ROOT%\bin\amos2.dmp -O %SWARD_ROOT%/SWARD/src/amosql/mkdmp.amosql

GOTO END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END