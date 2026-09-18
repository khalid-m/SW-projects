call Compile.cmd

cd %AMOS_HOME%\wsmed\WSBench\
call copy.cmd;

cd %AMOS_HOME%\wsmed\WSBench\
call WSMOS_DB_Server.cmd

cd %AMOS_HOME%\wsmed\WSBench\
call WSMOS_web_Server.cmd

cd %AMOS_HOME%\wsmed\WSBench\
call loadfunction.cmd;



