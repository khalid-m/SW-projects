@echo off
set AMOS_EXE=%AMOSROOT%\bin\amos2
REM set AMOS_DMP=%AMOSROOT%\bin\amos2.dmp
set AMOS_DMP=img.dmp

start "ISY" /min %AMOS_EXE% %AMOS_DMP% isydb.osql
start "IDA" /min %AMOS_EXE% %AMOS_DMP% idadb.osql

REM start "CLIENT"   %AMOSROOT%\bin\amos2 %AMOSROOT%\bin\amos2.dmp client.osql