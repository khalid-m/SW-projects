@echo off

java -ms64m -mx1024m -classpath "%CLASSPATH%;../src/classes;%AMOS_HOME%/bin/RDFamos.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar" JavaAMOS "%AMOS_HOME%\sard\sard_new\sard.dmp" -O %AMOS_HOME%/sard/sard_new/regress/company.amosql -o "quit;" 


GOTO END

:END







