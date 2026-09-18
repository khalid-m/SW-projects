@echo off
IF "%CLASSPATH%"=="" GOTO noclasspath
IF "%CATALINA_HOME%"=="" GOTO nocatalina

pushd Java
javac -classpath "%CLASSPATH%;%catalina_home%/common/lib/jsp-api.jar;%catalina_home%/common/lib/jasper-compiler.jar;%catalina_home%/common/lib/servlet-api.jar" -d ../WEB-INF/classes *.java
popd   

goto end;
:noclasspath
echo CLASSPATH not set. Must include javaamos.jar.
goto end

:nocatalina
echo CATALINA_HOME not set. Must be set to TomCat home directory.
goto end
:end

