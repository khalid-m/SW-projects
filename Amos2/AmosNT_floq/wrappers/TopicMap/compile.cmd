@echo off

IF EXIST classes\*.class del classes\*.class /q

call env.cmd

javac -classpath %AMOS_HOME%\bin\javaamos.jar;%LIB%\tm4j-0.9.7.jar;%LIB%\resolver.jar;%LIB%\mango.jar;%LIB%\commons-logging.jar  -d %AMOS_HOME%\wrappers\TopicMap\classes %AMOS_HOME%\wrappers\TopicMap\src\TMWrapper.java

pushd classes
jar -cf %LIB%\swatm.jar *.class 
popd

