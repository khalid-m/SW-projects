@echo off
echo Starting Goovi...
set SAVECLASSPATH=%CLASSPATH%
set CLASSPATH=.;javaamos.jar;..\bin\javaamos.jar;%CLASSPATH%
start javaw Goovi.Starter ../bin/amos2.dmp
set CLASSPATH=%SAVECLASSPATH%
