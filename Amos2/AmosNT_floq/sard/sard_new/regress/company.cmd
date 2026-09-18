@echo off


java -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes;%AMOS_HOME%/bin/sward.jar;%AMOS_HOME%/bin/RDFamos.jar;" SWARD "%AMOS_HOME%\sard\sard_new\sard.dmp" %AMOS_HOME%/sard/sard_new/regress/company.amosql -o "quit;"

GOTO END

:END







