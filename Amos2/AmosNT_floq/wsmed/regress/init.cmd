
pushd "%AMOS_HOME%"embeddings\wsmos
set WSDL_HOME= %AMOS_HOME%wsmed\regress\wsmos
start java -cp WEB-INF\classes;WEB-INF\lib\activation.jar;WEB-INF\lib\axis.jar;WEB-INF\lib\axis-ant.jar;WEB-INF\lib\commons-discovery-0.2.jar;WEB-INF\lib\commons-logging-1.0.4.jar;WEB-INF\lib\jaxrpc.jar;WEB-INF\lib\log4j-1.2.8.jar;WEB-INF\lib\mail.jar;WEB-INF\lib\saaj.jar;WEB-INF\lib\wsdl4j-1.5.1.jar;WEB-INF\lib\xercesImpl.jar;WEB-INF\lib\xml-apis.jar;WEB-INF\lib\servlet-api.jar;WEB-INF\lib\jasper-runtime.jar;WEB-INF\lib\jsp-api.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "%AMOS_HOME%bin/amos2.dmp" "WEB-INF/src/amosql/server.osql"

start /b  java -cp WEB-INF\src\amosql;WEB-INF\classes;WEB-INF\lib\activation.jar;WEB-INF\lib\axis.jar;WEB-INF\lib\axis-ant.jar;WEB-INF\lib\commons-discovery-0.2.jar;WEB-INF\lib\commons-logging-1.0.4.jar;WEB-INF\lib\jaxrpc.jar;WEB-INF\lib\log4j-1.2.8.jar;WEB-INF\lib\mail.jar;WEB-INF\lib\saaj.jar;WEB-INF\lib\wsdl4j-1.5.1.jar;WEB-INF\lib\xercesImpl.jar;WEB-INF\lib\xml-apis.jar;WEB-INF\lib\servlet-api.jar;WEB-INF\lib\jasper-runtime.jar;WEB-INF\lib\jsp-api.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "%AMOS_HOME%bin/amos2.dmp" "WEB-INF/src/amosql/client.osql"

start /b java -cp WEB-INF\classes;WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "%AMOS_HOME%WEB-INF/wsmos.dmp" "WEB-INF/src/amosql/start_server.osql"

pushd "%AMOS_HOME%"embeddings\wsmos\AmosWebServer

start /b java -cp %AMOS_HOME%embeddings\wsmos\AmosWebServer;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\axis.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\saaj.jar;%AMOS_HOME%bin\javaamos.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.AmosSoapServer
popd
popd
