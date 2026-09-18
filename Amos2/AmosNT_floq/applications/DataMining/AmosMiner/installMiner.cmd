IF not "%AMOS_HOME%"=="" set AHOME=%AMOS_HOME%
IF "%AMOS_HOME%"=="" set AHOME=..\
pushd %~p0
%AHOME%\bin\amos2 -o "loadsystem('MiningFunctions','master.osql'); save 'amosMiner.dmp'; quit;"
popd
