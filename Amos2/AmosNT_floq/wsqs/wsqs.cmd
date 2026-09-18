
start /min amos2 -n

pushd .


echo --------------------------------------------------
echo loading couresmanager functions  .....
echo --------------------------------------------------

cd %AMOS_HOME%\embeddings\Javascript\CourseManager\
call setup_wsmos.cmd

echo --------------------------------------------------
echo starting  WSMED webserver .....
echo --------------------------------------------------

cd %AMOS_HOME%\embeddings\wsmos\AmosWebServer\

call udblstartwsmosserver.cmd

echo --------------------------------------------------
echo starting  Database Server(WSMOS) .....
echo --------------------------------------------------


call udblstartWSMEDDatabase.cmd 



cd %AMOS_HOME%\embeddings\Javascript\CourseManager\

call %AMOS_HOME%\wsmed\wait 3
echo --------------------------------------------------
echo Creating WSDL and deploying web service for coursemanager 
echo --------------------------------------------------
call create_wsdl.cmd
call deploy.cmd

popd