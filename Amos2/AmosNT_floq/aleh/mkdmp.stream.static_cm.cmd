@echo off

cd osql
..\..\wrappers\ROOTWrap\ROOTWrap.exe rootwrap.dmp < "master.stream.static_cm.osql"
cd ..

IF NOT EXIST aleh_stream.static_cm.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating image file for streaming approach  
echo *  with structs is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end
