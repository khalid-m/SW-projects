@echo off
call checkenv

IF "%1" == "" goto :top
IF "%1" == "edutella" goto :top
IF "%1" == "pselo" goto :pselo

:pselo
IF "%MSSQL_HOME%"=="" goto :nomssql
set EXTENSION="src/amosql/pselo.amosql"
goto :top

:nomssql
echo **************************************************************************
echo * Please set environment variable %MSSQL_HOME% to point to your Microsoft
echo * JDBC driver dir.
echo * Press a key to exit.
echo **************************************************************************
pause
goto :end

:top
"%java_home%java" -classpath "%CLASSPATH%;%MSSQL_HOME%\msbase.jar;%MSSQL_HOME%\mssqlserver.jar;%MSSQL_HOME%\msutil.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/xmlAPIs.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar;%AMOS_HOME%/wrappers/rdf/classes" JavaAMOS %AMOS_HOME%\bin\edutella.dmp %EXTENSION%

set EXTENSION=

:end