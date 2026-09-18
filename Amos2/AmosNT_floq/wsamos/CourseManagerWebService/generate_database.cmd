@echo off
rem generates client and server Amos II images for the course manager
IF "%1%"=="" GOTO nodatabase
set here=%CD%

pushd osql
amos2 -O "server.osql" -o "generate_server('%1','%here%','%2');"
amos2 -O "client.osql" -o "generate_client('%1','%here%');"
popd
goto end

:nodatabase
echo Specify course manager ID as parameter!
goto end

:end