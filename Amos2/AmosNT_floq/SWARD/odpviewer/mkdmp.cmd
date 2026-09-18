@echo off

pushd ..
call compile
popd

java -classpath "..\..\bin\sward.jar;%CLASSPATH%" JavaAMOS ..\..\bin\amos2.dmp src/mkdmp.amosql
