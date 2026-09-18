@echo off

IF "%AMOS_HOME%"=="" goto noamoshome

rem AMOS_HOME is set first in PATH to handle scenario when local AMOS_HOME and global AMOS_HOME environment variables does not agree.
set PATH=%AMOS_HOME%\bin;%PATH%

goto end

:noamoshome
echo *******************************************************************************
echo * Please set environment variable AMOS_HOME first!
echo * However, if you are using the .zip distribution, everything is OK. 
echo * Press any key to exit/continue.
echo *******************************************************************************
pause
goto end

:end
