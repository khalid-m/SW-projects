pushd "%AMOS_HOME%"embeddings\wsmos\AmosWebServer

start /b java -cp %AMOS_HOME%embeddings\wsmos\AmosWebServer;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\axis.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\saaj.jar;%AMOS_HOME%bin\javaamos.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.AmosSoapServer

popd

