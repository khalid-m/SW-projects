@echo off

echo --------------------------------------------------
echo Patching amos function signature format
echo --------------------------------------------------

pushd ..\bin
copy amos2.dmp amos2.org.dmp
amos2 -o "load_lisp('../lsp/oldsig.lsp');save 'amos2.dmp';quit;"
popd

set   tempcp=%CLASSPATH%
echo --------------------------------------------------
echo starting  name server 
echo --------------------------------------------------

start /min amos2 -n

echo --------------------------------------------------
echo starting  standalone Amos web server .....
echo --------------------------------------------------

pushd "%AMOS_HOME%\"embeddings\wsmos\AmosWebServer
call setup
call compile


:st00
call %AMOS_HOME%\wsmed\wait 1
set /a count0=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.class) do (set /a count0+=1)
if %count0% lss 14 (goto :st00) 

start /MIN java -cp %CLASSPATH%;%AMOS_HOME%\embeddings\wsmos\AmosWebServer;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\saaj.jar;%AMOS_HOME%\bin\javaamos.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\QuickServer.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\commons-httpclient-3.0-rc4.jar;%AMOS_HOME%\embeddings\wsmos\AmosWebServer\lib\commons-pool.jar; org.AmosSoapServer.AmosSoapServer

popd

pushd %AMOS_HOME%\embeddings\wsmos\

set WSDL_HOME= %AMOS_HOME%\wsmed\wsdl\

start /b  javac -cp  %CLASSPATH%;%AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%\wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%\wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%\wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar  -d WEB-INF\classes WEB-INF\src\server\*.java

:st0
call %AMOS_HOME%\wsmed\wait 1
set /a count0=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.class) do (set /a count0+=1)
if %count0% lss 4 (goto :st0) 

start /b  javac -cp  %CLASSPATH%;%AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%\wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%\wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%\wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar  -d WEB-INF\classes WEB-INF\src\wsdlcreator\*.java

:st1
call %AMOS_HOME%\wsmed\wait 1
set /a count1=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.class) do (set /a count1+=1)
if %count1% lss 20 (goto :st1) 


start /b  java -cp  %CLASSPATH%;%AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%\wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%\wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%\wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS %AMOS_HOME%/bin/amos2.dmp WEB-INF/src/amosql/server.osql

start /b java -cp  %CLASSPATH%;%AMOS_HOME%\embeddings\wsmos\WEB-INF\classes;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\activation.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\axis-ant.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-discovery-0.2.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\commons-logging-1.0.4.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\jaxrpc.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\log4j-1.2.8.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\mail.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\saaj.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xercesImpl.jar;%AMOS_HOME%\embeddings\wsmos\WEB-INF\lib\xml-apis.jar;%AMOS_HOME%\wsmed\regress\lib\servlet-api.jar;%AMOS_HOME%\wsmed\regress\lib\jasper-runtime.jar;%AMOS_HOME%\wsmed\regress\lib\jsp-api.jar;%AMOS_HOME%\bin\javaamos.jar JavaAMOS %AMOS_HOME%/bin/amos2.dmp WEB-INF/src/amosql/client.osql


:st2
call  %AMOS_HOME%\wsmed\wait 1
set /a count2=0
for /r %AMOS_HOME%\embeddings\wsmos %%X in (*.dmp) do (set /a count2+=1)
if %count2% lss 2 (goto :st2) 


echo --------------------------------------------------
echo starting  database server ....
echo --------------------------------------------------

start /MIN java -cp %CLASSPATH%;WEB-INF\classes;WEB-INF\lib\wsdl4j-1.5.1.jar;%AMOS_HOME%\bin\javaamos.jar; JavaAMOS "WEB-INF/wsmos.dmp" -o "register('WSMOS');listen();"




popd

echo --------------------------------------------------
echo Starting WSMED...............
echo --------------------------------------------------

call setup.cmd
call compile.cmd
call mkdmp.cmd
echo --------------------------------------------------
echo Testing record structure and then PAP operator...............
echo --------------------------------------------------
:st3
call wait 1
set /a count3=0
for /r %AMOS_HOME%\wsmed %%X in (*.class,*.dmp) do (set /a count3+=1)
if %count3% lss 14 (goto :st3) 



call java JavaAMOS wsmed.dmp -O src/amosql/testcoroutine1.amosql
call wait 3

pushd "%AMOS_HOME%\"embeddings\wsmos\AmosWebServer
call killSoapServer.cmd
popd
set CLASSPATH=%tempcp%

rem Since amos2.dmp was patched:
copy ..\bin\amos2.org.dmp ..\bin\amos2.dmp
del ..\bin\amos2.org.dmp

