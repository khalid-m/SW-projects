@echo off

IF "%INTERBASE_BIN%"=="" goto NOINTERBASEBIN

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT

if exist "%SWARD_ROOT%\bin\SQ.gdb" del "%SWARD_ROOT%\bin\SQ.gdb"

echo create database "%SWARD_ROOT%\bin\SQ.gdb"; | "%INTERBASE_BIN%\isql.exe" -u sysdba -p masterkey 
"%INTERBASE_BIN%\isql.exe" -u sysdba -p masterkey -input %SWARD_ROOT%\SWARD\experiment\synopt10.sql %SWARD_ROOT%\bin\SQ.gdb"  

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
