@echo off

IF "%AMOS_HOME%"=="" goto noamoshome

rem AMOS_HOME is set first in PATH to handle scenario when local AMOS_HOME and global AMOS_HOME environment variables does not agree.
set PATH=%AMOS_HOME%\bin;%PATH%

IF "%JENA_HOME%"=="" goto nojenahome


goto end

:nojenahome
echo *******************************************************************************
echo * Please set environment variable JENA_HOME first!
echo * Press a key to exit.
echo *******************************************************************************
pause
goto end

:noamoshome
echo *******************************************************************************
echo * Please set environment variable AMOS_HOME first!
echo * However, if you are using the .zip distribution, everything is OK. 
echo * Press a key to exit/continue.
echo *******************************************************************************
pause
goto end

:end
