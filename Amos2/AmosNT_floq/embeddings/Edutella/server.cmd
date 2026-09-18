@echo off
call checkenv
"%java_home%java" -classpath "%CLASSPATH%;%MSSQL_HOME%\msbase.jar;%MSSQL_HOME%\mssqlserver.jar;%MSSQL_HOME%\msutil.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/xmlAPIs.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar;%AMOS_HOME%/wrappers/rdf/classes" JavaAMOS pselo.dmp server.amosql








