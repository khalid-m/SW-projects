@echo off

rem This script compiles Java code, installs CM, and restarts TomCat

IF "%CLASSPATH%"=="" GOTO noclasspath
IF "%CATALINA_HOME%"=="" GOTO nocatalina

net stop "Apache Tomcat"

mkdir "%CATALINA_HOME%\webapps\CourseManager"
copy "%AMOS_HOME%\bin\javaamos.jar" "%CATALINA_HOME%\shared\lib"

net start "Apache Tomcat"

call compile.cmd

call copycode.cmd

net stop "Apache Tomcat"
net start "Apache Tomcat"

goto end;

:noclasspath
echo CLASSPATH not set. Must include javaamos.jar.
goto end

:nocatalina
echo CATALINA_HOME not set. Must be set to TomCat home directory.
goto end

:end

