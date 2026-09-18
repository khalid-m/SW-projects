@echo off

if not exist class mkdir class
if exist class\logdir\LogDir.class del class\logdir\LogDir.class

if not exist lib mkdir lib
if exist lib\logdir.jar del lib\logdir.jar

javac -d class src\Java\logdir\LogDir.java

pushd class
jar -cf %AMOS_HOME%\logdir\lib\logdir.jar *
popd
