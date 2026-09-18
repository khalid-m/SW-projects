@echo off
IF "%AMOS_HOME%"=="" GOTO setamos
pushd sparql_interface
"%JAVA_HOME%javac" -classpath %AMOS_HOME%/bin/javaamos.jar SparQLQuery.java
popd
GOTO done
:setamos
echo Please set AMOS_HOME
:done
