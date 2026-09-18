@echo off
echo -------------- Testing materialized ontology, loading entire file ---
IF NOT EXIST aleh.exe GOTO aleh_failed
IF NOT EXIST aleh_load.dmp GOTO dmp_failed
aleh aleh_load.dmp regress/materialized.load.osql -o "quit;"
goto end

:aleh_failed
echo ****************************************
echo * aleh.exe does not exist
echo * Press any key
echo ****************************************
pause 
goto end

:dmp_failed
echo *****************************************************************************
echo * aleh_load.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end