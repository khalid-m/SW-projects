@echo off
if not "%INTERBASE_BIN%"=="" GOTO firebird
call mysqltest.cmd
goto end
:firebird
call firebirdtest.cmd
:end
