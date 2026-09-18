@echo off

IF EXIST sard.dmp del sard.dmp /q

java -classpath "%CLASSPATH%;src/classes;" JavaAMOS "%AMOS_HOME%/bin/amos2.dmp" src/mkdmp.amosql

