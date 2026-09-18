@echo off
IF "%CLASSPATH%"=="" GOTO noclasspath
IF "%CATALINA_HOME%"=="" GOTO nocatalina

pushd WEB-INF\src
javac  -d ..\classes server\*.java
javac  -d ..\classes wsdlcreator\*.java
popd
goto end;

:noclasspath
echo CLASSPATH not set. Must include javaamos.jar.
goto end

:nocatalina
echo CATALINA_HOME not set. Must be set to TomCat home directory.
goto end
:end
