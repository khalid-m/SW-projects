@echo off
IF NOT EXIST %AMOS_HOME%\bin\amos2.lib GOTO create_lib
goto compile

:create_lib
echo ************************************
echo * amos2.lib is not created!
echo * compiling amos2.lib ....
echo ************************************
pushd %AMOS_HOME%\system\MVC
call compile
popd
IF NOT EXIST %AMOS_HOME%\bin\amos2.lib GOTO failed_lib
del ROOTWrap.exe

:compile
echo -------------------------- Compiling ROOT wrapper -------------------------
msdev ROOTWrap.dsw /make
IF NOT EXIST ROOTWrap.exe GOTO compile_failed
goto end

:failed_lib
echo **********************************
echo * amos2.lib was not created
echo **********************************

:compile_failed
echo ****************************************
echo * Compiling ROOT wrapper failed
echo * Press any key to exit
echo ****************************************
pause
goto end

:end