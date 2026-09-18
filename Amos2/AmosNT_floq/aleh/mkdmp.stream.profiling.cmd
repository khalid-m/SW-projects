@echo off

cd osql
..\..\wrappers\ROOTWrap\ROOTWrap.exe rootwrap.dmp < "master.stream.profiling.osql"
cd ..

IF NOT EXIST aleh_stream.profiling.dmp GOTO failed

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
