@echo off
set OLDCLASSPATH=%CLASSPATH%
set CLASSPATH=%CLASSPATH%;..\bin\w4f.jar;..\bin\xerces.jar;..\bin\patbin14_13.jar
java -Dw4fconfigfile=..\Java\lib\w4fconfig.txt w4f.Main %1 %2 %3 %4 %5
set CLASSPATH=%OLDCLASSPATH%