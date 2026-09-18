rem @echo off
IF "%CLASSPATH%"=="" GOTO noclasspath
IF "%CATALINA_HOME%"=="" GOTO nocatalina

net stop "Apache Tomcat"

call compile.cmd

mkdir "%CATALINA_HOME%\webapps\jspTopLoop"
xcopy /S /Y * "%CATALINA_HOME%\webapps\jspTopLoop"
copy "%AMOS_HOME%\bin\amos.dll" "%CATALINA_HOME%\bin"
copy "%AMOS_HOME%\bin\javaamos.dll" "%CATALINA_HOME%\bin"

copy %AMOS_HOME%\bin\javaamos.jar %CATALINA_HOME%\shared\lib

net start "Apache Tomcat"

goto end;

:noclasspath
echo CLASSPATH not set. Must include javaamos.jar.
goto end

:nocatalina
echo CATALINA_HOME not set. Must be set to TomCat home directory.
goto end

:end

