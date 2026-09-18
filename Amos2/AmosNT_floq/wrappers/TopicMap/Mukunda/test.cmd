@echo off
IF EXIST javaclasses\*.class del javaclasses\*.class /q
call env.cmd
call compile.cmd
call mkdmp.cmd

java -ms64m -mx512m -cp "../../bin/javaamos.jar;javaclasses;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/bin/RDFAmos.jar;%LIB%\tm4j-0.9.7.jar;%LIB%\commons-collections-2.1.1-2004-05-26.jar;%LIB%\tm4j-2002-09-16.jar;%LIB%\log4j-1.1.3-1980-01-01.jar;%LIB%/tm4j-0.9.7.jar;%LIB%/resolver.jar;%LIB%/mango.jar;%LIB%/commons-logging.jar" SWARD TAmos.dmp source/test.amosql
