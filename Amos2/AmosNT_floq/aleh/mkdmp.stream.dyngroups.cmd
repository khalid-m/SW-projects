@echo off

cd osql
..\..\wrappers\ROOTWrap\ROOTWrap.exe rootwrap.dmp < "master.stream.dyngroups.osql"
cd ..

IF NOT EXIST aleh_stream.dyngroups.dmp GOTO failed

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
