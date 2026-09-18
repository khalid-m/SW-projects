@echo off

cd osql
..\..\wrappers\ROOTWrap\ROOTWrap.exe rootwrap.dmp < "master.stream.osql"
cd ..

IF NOT EXIST aleh_stream.dmp GOTO failed

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
