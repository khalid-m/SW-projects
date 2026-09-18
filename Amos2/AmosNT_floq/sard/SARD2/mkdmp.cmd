@echo off

IF EXIST sard2.dmp del sard2.dmp /q

java -classpath "%CLASSPATH%;src/classes;" JavaAMOS "%AMOS_HOME%/bin/amos2.dmp" src/mkdmp.amosql

