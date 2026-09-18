@echo off

IF EXIST bin RMDIR .\bin /S /Q
mkdir bin

::bigtable.jar is the whole java code library
IF EXIST lib\bigtable.jar  del lib\bigtable.jar

::choice 1
::set CLASSPATH=%AMOS_HOME%\wrappers\Bigtable\lib\bigtable.jar;%CLASSPATH%;%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-codec-1.3.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-httpclient-3.1.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-logging-1.1.1.jar;

::choice 2 (original choice)
set CLASSPATH=%AMOS_HOME%\wrappers\Bigtable\src\Java;%AMOS_HOME%\wrappers\Bigtable\lib\bigtable.jar;%CLASSPATH%;%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-codec-1.3.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-httpclient-3.1.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-logging-1.1.1.jar;
::javac -classpath %AMOS_HOME%\wrappers\Bigtable\src\Java;%AMOS_HOME%\wrappers\Bigtable\lib\bigtable.jar;%CLASSPATH%;%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-codec-1.3.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-httpclient-3.1.jar;%AMOS_HOME%\wrappers\Bigtable\lib\jacarta-commons\commons-logging-1.1.1.jar;

ECHO Compiling java sources...
::choice 1
::javac -Xlint:-path -sourcepath src\Java -d bin src\Java\bigtable\*.java src\Java\bigtable\schema\SchemaManager.java

::choice 2
javac -Xlint:-path -d bin src\Java\bigtable\*.java src\Java\bigtable\schema\SchemaManager.java


pushd bin
jar -cf %AMOS_HOME%\wrappers\Bigtable\lib\bigtable.jar *
popd

::call mkdmp
