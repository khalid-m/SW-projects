@echo off

IF EXIST sard.dmp del sard.dmp /q


java -classpath "%CLASSPATH%;%NPATH%;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/wrappers/RDF/classes;src"  JavaAMOS ..\bin\amos2.dmp src/mkdmp.amosql

