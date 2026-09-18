
pushd .
cd c:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\
call C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\udblsetup.cmd
rem call setup.cmd
start /MIN java  -cp .;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\axis.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\saaj.jar;;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-pool.jar;C:\udbl\AmosNT\bin\javaamos.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;C:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.UDBLAmosSoapServer

popd


