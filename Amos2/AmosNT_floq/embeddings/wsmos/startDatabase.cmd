pushd WEB-INF
start java -cp classes;lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS wsmos.dmp src/amosql/start_server.osql
popd
