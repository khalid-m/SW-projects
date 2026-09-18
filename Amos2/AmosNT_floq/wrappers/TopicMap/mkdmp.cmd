@echo off

IF EXIST TAmos.dmp del TAmos.dmp /q

call env.cmd

pushd classes
java -classpath ".;%LIB%\tm4j-0.9.7.jar;%LIB%\resolver.jar;%LIB%\mango.jar;%LIB%\commons-logging.jar;%CLASSPATH%;classes;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/bin/RDFAmos.jar"  SWARD "%AMOS_HOME%/bin/amos2.dmp" ../src/mkdmp.amosql
popd classes



