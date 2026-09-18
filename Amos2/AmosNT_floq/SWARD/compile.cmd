@echo off

pushd %SWARD_ROOT%\SWARD\src\Java\swardAPI
javac -classpath "%SWARD_ROOT%\bin\javaamos.jar;%CLASSPATH%" -d %SWARD_ROOT%\SWARD\classes RDFScan.java 
javac -classpath "%SWARD_ROOT%\SWARD\classes;%SWARD_ROOT%bin\javaamos.jar;%CLASSPATH%" -d %SWARD_ROOT%\SWARD\classes RDFViewer.java 
javac -classpath "%SWARD_ROOT%\SWARD\classes;%SWARD_ROOT%bin\javaamos.jar;%CLASSPATH%" -d %SWARD_ROOT%\SWARD\classes TestEmbed.java 
popd

copy %SWARD_ROOT%\bin\javaamos.jar %SWARD_ROOT%\bin\sward.jar 

pushd %SWARD_ROOT%\SWARD\classes
jar -uf %SWARD_ROOT%\bin\sward.jar *.class 
jar -uf %SWARD_ROOT%\bin\sward.jar %SWARD_ROOT%\SWARD\classes\swardAPI *.class 
popd



