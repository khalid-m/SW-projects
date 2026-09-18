@echo off
IF "%PATH_WAS_SET%"=="" GOTO next
GOTO done
:next
set PATH=%AMOS_HOME%bin;%PATH%
set PATH_WAS_SET="1"
:done
