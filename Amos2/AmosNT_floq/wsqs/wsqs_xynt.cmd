start c:\udbl\AmosNT\bin\amos2.exe -n

pushd .


echo --------------------------------------------------
echo loading couresmanager functions  .....
echo --------------------------------------------------

cd  c:\udbl\AmosNT\embeddings\Javascript\CourseManager\
call  c:\udbl\AmosNT\embeddings\Javascript\CourseManager\setup_wsmos_udbl.cmd

echo --------------------------------------------------
echo starting  WSMED webserver .....
echo --------------------------------------------------

cd  c:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\

call c:\udbl\AmosNT\embeddings\wsmos\AmosWebServer\udblstartwsmosserver.cmd

echo --------------------------------------------------
echo starting  Database Server(WSMOS) .....
echo --------------------------------------------------


call udblstartWSMEDDatabase.cmd 



cd  c:\udbl\AmosNT\embeddings\Javascript\CourseManager\

call  c:\udbl\AmosNT\wsmed\wait 3
echo --------------------------------------------------
echo Creating WSDL and deploying web service for coursemanager 
echo --------------------------------------------------
call create_wsdl.cmd
call deploy_udbl.cmd

popd