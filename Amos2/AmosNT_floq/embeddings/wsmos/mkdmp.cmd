@echo off
IF "%WSDL_HOME%"=="" GOTO nowsdlhome
"java" JavaAMOS "%AMOS_HOME%/bin/amos2.dmp" WEB-INF/src/amosql/server.osql
"java" JavaAMOS "%AMOS_HOME%/bin/amos2.dmp" WEB-INF/src/amosql/client.osql
goto end
:nowsdlhome
echo Environment variable WSDL_HOME not set!
:end