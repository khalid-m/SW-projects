copy ..\bin\javaamos.jar jspamos.jar
pushd ..\Java
javac jspamos/*.java
jar uf ../applications/jspamos.jar jspamos/*.class
del jspamos\*.class
copy "%AMOS_HOME%\applications\jspamos.jar" "%CATALINA_HOME%\shared\lib"
del  "%AMOS_HOME%\applications\jspamos.jar"
popd