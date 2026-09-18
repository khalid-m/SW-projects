@echo off
call checkenv
pushd src\Java
"%java_home%javac" -classpath %AMOS_HOME%\bin\javaamos.jar;..\..\ea.jar -d %AMOS_HOME%\embeddings\Edutella\classes AmosProviderConnection.java
popd
pushd classes
"%java_home%jar" cf PSELO.jar pselo 
popd

