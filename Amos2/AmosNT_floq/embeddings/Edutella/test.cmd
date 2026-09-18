@echo off
call checkenv
IF "%1" == "" goto :edutella
IF "%1" == "simple" goto :edutella
IF "%1" == "full" goto :pselo

:pselo
IF "%MSSQL_HOME%"=="" goto :nomssql
set TESTSCRIPT="regress/pselo.amosql"
goto :top

:edutella
set TESTSCRIPT="regress/edutella.amosql"
goto :top

:nomssql
echo **************************************************************************
echo * Please set environment variable %MSSQL_HOME% to point to your Microsoft
     * JDBC driver dir.
echo * Press a key to exit.
echo **************************************************************************
pause
goto :end

:top
"%java_home%java" -classpath "%CLASSPATH%;%MSSQL_HOME%\msbase.jar;%MSSQL_HOME%\mssqlserver.jar;%MSSQL_HOME%\msutil.jar;%JENA_HOME%/lib/jena.jar;%JENA_HOME%/lib/xercesImpl.jar;%JENA_HOME%/lib/xmlAPIs.jar;%JENA_HOME%/lib/icu4j.jar;%JENA_HOME%/lib/commons-logging.jar;%AMOS_HOME%/wrappers/rdf/classes" JavaAMOS %AMOS_HOME%\bin\edutella.dmp %TESTSCRIPT%


:end

