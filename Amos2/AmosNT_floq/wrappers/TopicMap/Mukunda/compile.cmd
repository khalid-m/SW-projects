@echo off

IF EXIST javaclasses\*.class del javaclasses\*.class /q

call env.cmd

javac -classpath %AMOS_HOME%\bin\javaamos.jar;%LIB%\tm4j-0.9.7.jar;%LIB%\commons-collections-2.1.1-2004-05-26.jar;%LIB%\tm4j-2002-09-16.jar;%LIB%\log4j-1.1.3-1980-01-01.jar;%LIB%\resolver.jar;%LIB%\mango.jar;%LIB%\commons-logging.jar  -d %AMOS_HOME%\wrappers\TopicMap\Mukunda\javaclasses %AMOS_HOME%\wrappers\TopicMap\Mukunda\source\TMWrapper.java

pushd javaclasses
jar -cf %LIB%\swatm.jar *.class 
popd

