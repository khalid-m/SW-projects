@echo off

IF "%INTERBASE_BIN%"=="" goto nointerbasebin

if exist test.gdb del test.gdb 

echo create database 'test.gdb'; | "%interbase_bin%\isql.exe" -u sysdba -p masterkey
"%interbase_bin%\isql.exe" test.gdb -u sysdba -p masterkey -i regress.sql

call javaamos -O firebirdtest.amosql

goto end

:nointerbasebin
echo *******************************************************************************
echo Please set environment variable INTERBASE_BIN to point to Interbase binary directory!
echo *******************************************************************************
pause

:end

