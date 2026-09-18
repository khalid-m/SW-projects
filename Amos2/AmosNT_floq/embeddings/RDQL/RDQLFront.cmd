@echo off
java -classpath "%CLASSPATH%;%AMOS_HOME%/bin/RDFamos.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar" JavaAMOS %AMOS_HOME%/bin/amos2.dmp rdql.amosql
