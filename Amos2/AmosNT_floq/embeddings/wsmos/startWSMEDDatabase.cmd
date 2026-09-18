pushd "%AMOS_HOME%"\embeddings\wsmos
call setup
pushd WEB-INF
start java -cp classes;lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS wsmos.dmp src/amosql/wsqs.amosql
popd
popd