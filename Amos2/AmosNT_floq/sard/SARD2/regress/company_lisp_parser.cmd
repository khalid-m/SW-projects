@echo off

java -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes;%AMOS_HOME%/bin/RDFamos.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar" JavaAMOS "%AMOS_HOME%\sard\SARD2\sard2.dmp" -O %AMOS_HOME%/sard/SARD2/regress/company.amosql -o "quit;" 


GOTO END

:END







