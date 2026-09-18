@echo off
call checkenv
"%java_home%java" -classpath "%CLASSPATH%;%AMOS_HOME%/wrappers/rdf/classes" JavaAMOS %AMOS_HOME%/bin/amos2.dmp src/AmosQL/mkdmp.amosql

