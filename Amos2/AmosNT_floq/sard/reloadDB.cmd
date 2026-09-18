@echo off
IF "%INTERBASE_BIN%"=="" goto nointerbasebin

if exist "%interbase_bin%\reloadDB.gdb" del "%interbase_bin%\reloadDB.gdb"

echo create database "%interbase_bin%\reloadDB.gdb"; | "%interbase_bin%\isql.exe" -u sysdba -p masterkey  
goto end

:nointerbasebin
echo *************************************************************************************
echo Please set environment variable INTERBASE_BIN to point to Interbase binary directory!
echo *************************************************************************************
pause

goto end

:end