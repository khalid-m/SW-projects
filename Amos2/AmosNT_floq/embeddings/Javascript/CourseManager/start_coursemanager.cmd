@echo off

echo --------------------------------------------------
echo Starting WSMOS database server 
echo --------------------------------------------------
call start_database.cmd

rem wait some time for  database server
call  %AMOS_HOME%\wsmed\wait 1

echo --------------------------------------------------
echo Creating WSDL and deploying web service for coursemanager 
echo --------------------------------------------------
call create_wsdl.cmd
call deploy.cmd


echo --------------------------------------------------
echo Starting AmosSoapServer
echo --------------------------------------------------
call start_amos_server.cmd
