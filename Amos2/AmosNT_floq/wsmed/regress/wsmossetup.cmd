
echo --------------------------------------------------
echo starting  name server 
echo --------------------------------------------------
@echo off 
start /min amos2 -n

echo --------------------------------------------------
echo starting  standalone Amos web server .....
echo --------------------------------------------------

pushd "%AMOS_HOME%"embeddings\wsmos\AmosWebServer
call setup

call compile
popd

pushd "%AMOS_HOME%"embeddings\wsmos\AmosWebServer

start /MIN java -cp %AMOS_HOME%embeddings\wsmos\AmosWebServer;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\axis.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\saaj.jar;%AMOS_HOME%bin\javaamos.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;%AMOS_HOME%embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.AmosSoapServer

popd

pushd %AMOS_HOME%embeddings\wsmos\

set WSDL_HOME= %AMOS_HOME%wsmed\regress\
:st1
start /b  javac -cp  %AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar  -d WEB-INF\classes WEB-INF\src\server\*.java

start /b  javac -cp  %AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar  -d WEB-INF\classes WEB-INF\src\wsdlcreator\*.java


set /a count1=0
for /r %AMOS_HOME%embeddings\wsmos %%X in (*.class) do (set /a count1+=1)
echo %count1%
if %count1% lss 19 (goto :st1) 

start  java -cp  %AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS %AMOS_HOME%/bin/amos2.dmp WEB-INF/src/amosql/server.osql

start  java -cp  %AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS %AMOS_HOME%/bin/amos2.dmp WEB-INF/src/amosql/client.osql

:st2
set /a count2=0
for /r %AMOS_HOME%embeddings\wsmos %%X in (*.dmp) do (set /a count2+=1)
echo %count2%
if %count2% lss 2 (goto :st2) 


echo --------------------------------------------------
echo starting  database server ....
echo --------------------------------------------------

start  java -cp WEB-INF\classes;WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%bin\javaamos.jar; JavaAMOS "WEB-INF/wsmos.dmp" -o "register('WSMOS');listen();"




popd

echo --------------------------------------------------
echo Starting WSMED...............
echo --------------------------------------------------
call setup.cmd
call compile.cmd
call mkdmp.cmd
echo --------------------------------------------------
echo Testing ff_applyp...............
echo --------------------------------------------------
call java JavaAMOS wsmed.dmp -O src/amosql/testcoroutine1.amosql

 call amos2 -O src/amosql/testcoroutine4.amosql