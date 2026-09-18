@echo off
echo -------------- Testing materialized ontology, loading entire file ---
echo -------------- dynamic group cost model ---
IF NOT EXIST aleh.exe GOTO aleh_failed
IF NOT EXIST aleh_load.cost_model.dynamic.dmp GOTO dmp_failed
aleh aleh_load.cost_model.dynamic.dmp regress/materialized.load.dynamic.osql -o "quit;"
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
echo * aleh_load.cost_model.dynamic.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
