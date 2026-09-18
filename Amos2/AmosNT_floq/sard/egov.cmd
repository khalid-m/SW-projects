@echo off
IF "%INTERBASE_BIN%"=="" goto nointerbasebin

if exist "%interbase_bin%\eGov.gdb" del "%interbase_bin%\eGov.gdb"

echo create database "%interbase_bin%\eGov.gdb"; | "%interbase_bin%\isql.exe" -u sysdba -p masterkey 
"%interbase_bin%\isql.exe" -u sysdba -p masterkey -input egov.sql "%interbase_bin%\eGov.gdb"  

goto end

:nointerbasebin
echo *************************************************************************************
echo Please set environment variable INTERBASE_BIN to point to Interbase binary directory!
echo *************************************************************************************
pause

goto end

:end