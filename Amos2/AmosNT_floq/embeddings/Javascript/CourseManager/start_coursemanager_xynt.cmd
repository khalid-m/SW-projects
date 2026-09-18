@echo off
pushd  c:\UDBL\AmosNT\bin
start  amos2 -n
rem wait some time for  nameserver startup
call  c:\UDBL\AmosNT\wsmed\wait 3


set AMOS_HOME=c:/UDBL/AmosNT/
echo --------------------------------------------------
echo Starting WSMOS database server 
echo --------------------------------------------------

pushd  c:\UDBL\AmosNT\embeddings\wsmos\
call setup.cmd
call startDatabase.cmd
popd

rem wait some time for  database server startup
call  c:\UDBL\AmosNT\wsmed\wait 2

echo --------------------------------------------------
echo Creating WSDL and deploying web service for coursemanager 
echo --------------------------------------------------
call create_wsdl.cmd
call deploy.cmd


rem wait some time for  database server startup
rem call  c:\UDBL\AmosNT\wsmed\wait 2
echo --------------------------------------------------
echo starting  standalone Amos web server .....
echo --------------------------------------------------

pushd c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer
call setup
call compile
start /MIN java -cp %CLASSPATH%;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\axis.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\saaj.jar;c:\UDBL\AmosNT\bin\javaamos.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;c:\UDBL\AmosNT\embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.AmosSoapServer

popd
