@echo off

IF "%SWARD_ROOT%"=="" GOTO NOSWARDROOT
IF "%INTERBASE_BIN%"=="" goto MYSQLSETUP
set URLDB=jdbc:interbase://localhost/%SWARD_ROOT%/bin/COMPANY.gdb
set DRIVERDB=interbase.interclient.Driver
set USERDB=SYSDBA
set PASSWORDDB=masterkey

if exist "%SWARD_ROOT%\bin\COMPANY.gdb" del "%SWARD_ROOT%\bin\COMPANY.gdb"

echo create database "%SWARD_ROOT%\bin\COMPANY.gdb"; | "%INTERBASE_BIN%\isql.exe" -u sysdba -p masterkey 
"%INTERBASE_BIN%\isql.exe" -u sysdba -p masterkey -input %SWARD_ROOT%\SWARD\regress\company.sql %SWARD_ROOT%\bin\COMPANY.gdb"  
"%INTERBASE_BIN%\isql.exe" -u sysdba -p masterkey -input %SWARD_ROOT%\SWARD\regress\egov.sql %SWARD_ROOT%\bin\COMPANY.gdb"  

goto END

:MYSQLSETUP
set URLDB=jdbc:mysql://localhost:3306/regress
set DRIVERDB=com.mysql.jdbc.Driver
set USERDB=regress
set PASSWORDDB=regress

call javaamos -O mysqlpopulate.osql

goto end

:NOSWARDROOT
echo *******************************************************************************
echo Please set environment variable SWARD_ROOT by calling setup.cmd.
echo *******************************************************************************
pause

:END

