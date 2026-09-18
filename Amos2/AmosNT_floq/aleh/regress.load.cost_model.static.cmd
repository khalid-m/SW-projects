@echo off
echo -------------- Testing materialized ontology, loading entire file ---
echo -------------- complete static cost model ---
IF NOT EXIST aleh.exe GOTO aleh_failed
IF NOT EXIST aleh_load.cost_model.static.dmp GOTO dmp_failed
aleh aleh_load.cost_model.static.dmp regress/materialized.load.static.osql -o "quit;"
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
echo * aleh_load.cost_model.static.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
