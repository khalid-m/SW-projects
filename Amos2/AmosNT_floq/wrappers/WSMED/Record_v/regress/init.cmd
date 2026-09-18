pushd "%AMOS_HOME%"embeddings\wsmos


start java -cp WEB-INF\classes;WEB-INF\lib\activation.jar;WEB-INF\lib\axis.jar;WEB-INF\lib\axis-ant.jar;WEB-INF\lib\commons-discovery-0.2.jar;WEB-INF\lib\commons-logging-1.0.4.jar;WEB-INF\lib\jaxrpc.jar;WEB-INF\lib\log4j-1.2.8.jar;WEB-INF\lib\mail.jar;WEB-INF\lib\saaj.jar;WEB-INF\lib\wsdl4j-1.5.1.jar;WEB-INF\lib\xercesImpl.jar;WEB-INF\lib\xml-apis.jar;WEB-INF\lib\servlet-api.jar;WEB-INF\lib\jasper-runtime.jar;WEB-INF\lib\jsp-api.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "%AMOS_HOME%bin/amos2.dmp" WEB-INF/src/amosql/server.osql"

start  java -cp WEB-INF\src\amosql;WEB-INF\classes;WEB-INF\lib\activation.jar;WEB-INF\lib\axis.jar;WEB-INF\lib\axis-ant.jar;WEB-INF\lib\commons-discovery-0.2.jar;WEB-INF\lib\commons-logging-1.0.4.jar;WEB-INF\lib\jaxrpc.jar;WEB-INF\lib\log4j-1.2.8.jar;WEB-INF\lib\mail.jar;WEB-INF\lib\saaj.jar;WEB-INF\lib\wsdl4j-1.5.1.jar;WEB-INF\lib\xercesImpl.jar;WEB-INF\lib\xml-apis.jar;WEB-INF\lib\servlet-api.jar;WEB-INF\lib\jasper-runtime.jar;WEB-INF\lib\jsp-api.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "%AMOS_HOME%bin/amos2.dmp" "WEB-INF/src/amosql/client.osql"


popd
exit;