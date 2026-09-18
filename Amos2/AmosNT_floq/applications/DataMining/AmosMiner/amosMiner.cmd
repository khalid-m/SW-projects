@echo off
IF not "%AMOS_HOME%"=="" set AHOME=%AMOS_HOME%
IF "%AMOS_HOME%"=="" set AHOME=%~p0\..
if "%1" == "" "%AHOME%\bin\amos2" "%~p0\amosMiner.dmp"
if not "%1" == "" "%AHOME%\bin\amos2" %1 %2 %3 %4 %5 %6 %7 %8 %9
