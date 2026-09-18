set AMOS_HOME=C:\udbl\AmosNT\
pushd "%AMOS_HOME%"\embeddings\wsmos\AmosWebServer\
call udblsetup.cmd
pushd  "%AMOS_HOME%"\embeddings\wsmos\WEB-INF

start java -cp classes;lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS wsmos.dmp src/amosql/wsqs.amosql
popd
popd