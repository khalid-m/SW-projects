@echo off

IF "%INTERBASE_BIN%"=="" goto NOINTERBASEBIN

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

if exist "%SWARD_ROOT%\bin\EGOVERNMENT.gdb" del "%SWARD_ROOT%\bin\EGOVERNMENT.gdb"

echo create database "%SWARD_ROOT%\bin\EGOVERNMENT.gdb"; | "%interbase_bin%\isql.exe" -u sysdba -p masterkey 
"%interbase_bin%\isql.exe" -u sysdba -p masterkey -input %SWARD_ROOT%\SWARD\regress\egov.sql %SWARD_ROOT%\bin\EGOVERNMENT.gdb"  

goto END

:NOINTERBASEBIN
echo *************************************************************************************
echo Please set environment variable INTERBASE_BIN to point to Interbase binary directory!
echo *************************************************************************************
pause

goto END

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

goto END

:END

