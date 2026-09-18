@echo off

call compile.cmd
call mkdmp.cmd

java -ms64m -mx512m -cp "../../bin/javaamos.jar;classes;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/bin/RDFAmos.jar;lib/tm4j-0.9.7.jar;lib/resolver.jar;lib/mango.jar;lib/commons-logging.jar" SWARD TAmos.dmp regress/test.amosql
