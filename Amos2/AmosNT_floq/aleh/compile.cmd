@echo off
IF NOT EXIST %AMOS_HOME%\bin\amoslib.lib GOTO create_lib
goto compile

:create_lib
echo ************************************
echo * amoslib.lib is not created!
echo * compiling amoslib.lib ....
echo ************************************
pushd %AMOS_HOME%\system\MVC
call compile
popd
IF NOT EXIST %AMOS_HOME%\bin\amoslib.lib GOTO failed_lib
del aleh.exe

:compile
echo ----------------------- Compiling ALEH ------------------------
msdev aleh.dsw /make
IF NOT EXIST aleh.exe GOTO compile_failed
goto end

:failed_lib
echo **********************************
echo * amoslib.lib was not created
echo 

:compile_failed
echo ****************************************
echo * Compiling ALEH failed
echo * Press any key to exit
echo ****************************************
pause
goto end

:end