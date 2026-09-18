@echo off
IF "%CLASSPATH%"=="" GOTO noclasspath


javac org\jSoapServer\http\*.java
javac org\jSoapServer\utils\*.java
javac -cp "%CLASSPATH%";.; org\AmosSoapServer\*.java

goto end;

:noclasspath
echo CLASSPATH not set. Must include javaamos.jar.
goto end

:end
