@echo off
if not exist lib\logdir.jar call compile.cmd
if not exist logdir.dmp call mkdmp.cmd
java -cp "%AMOS_HOME%\logdir\lib\logdir.jar;%CLASSPATH%" JavaAMOS logdir.dmp