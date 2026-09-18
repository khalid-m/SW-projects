@echo off
set SAVECLASSPATH=%CLASSPATH%
set CLASSPATH=../bin/orwise.jar;../bin/w4f.jar;../bin/xerces.jar;../bin/patbin14_13.jar;%CLASSPATH%
call javaamos %1 %2
set CLASSPATH=%SAVECLASSPATH%

