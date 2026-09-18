@echo off
echo --------------------------------------------------
echo Starting WSMOS...........
echo --------------------------------------------------
call startwsmos.cmd

REM Wait For a while 
@ping 127.0.0.1 -n 5 -w 1000 > nul
@ping 127.0.0.1 -n %1% -w 1000> nul


echo --------------------------------------------------
echo Creating WSDL...............
echo --------------------------------------------------
start  amos2 -c "me" -O "src/amosql/create_wsdl.amosql" 

echo --------------------------------------------------
echo Starting WSMED...............
echo --------------------------------------------------
call setup.cmd
call mkdmp

echo --------------------------------------------------
echo Executing query ********** select 3=intPlus(1,2);
echo --------------------------------------------------
start /b "java" JavaAMOS wsmed.dmp "src/amosql/test_wsmed.amosql"

REM Wait For a while 
@ping 127.0.0.1 -n 5 -w 1000 > nul
@ping 127.0.0.1 -n %1% -w 1000 > nul

start amos2 -c "killer" -o "kill_all_peers(); quit;" 
