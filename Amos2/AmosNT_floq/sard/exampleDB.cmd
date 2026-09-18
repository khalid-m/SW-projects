@echo off
IF "%INTERBASE_BIN%"=="" goto nointerbasebin

if exist "%interbase_bin%\exampleDB.gdb" del "%interbase_bin%\exampleDB.gdb"

echo create database "%interbase_bin%\exampleDB.gdb"; | "%interbase_bin%\isql.exe" -u sysdba -p masterkey 
"%interbase_bin%\isql.exe" -u sysdba -p masterkey -input exampleDB.sql "%interbase_bin%\exampleDB.gdb"  

goto end

:nointerbasebin
echo *************************************************************************************
echo Please set environment variable INTERBASE_BIN to point to Interbase binary directory!
echo *************************************************************************************
pause

goto end

:end



