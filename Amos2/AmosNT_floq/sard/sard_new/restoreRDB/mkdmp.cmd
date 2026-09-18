@echo off

IF EXIST restore.dmp del restore.dmp /q
call javaamos mkdmp.amosql

