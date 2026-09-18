@echo off
pushd MVC
msdev JavaSCSQ.dsp /MAKE
popd

pushd java
echo Making java...
javac -classpath "..\..\..\bin\javaamos.jar;%CLASSPATH%" -d ..\classes JavaSCSQ.java
popd
pushd classes
jar cf ../../../bin/javascsq.jar *
popd
