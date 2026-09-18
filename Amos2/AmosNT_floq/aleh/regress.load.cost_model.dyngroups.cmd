@echo off
echo -------------- Testing materialized ontology, loading entire file ---
echo -------------- dynamic pfoiled group cost model generation ---
IF NOT EXIST aleh.exe GOTO aleh_failed
IF NOT EXIST aleh_load.cost_model.dyngroups.dmp GOTO dmp_failed
aleh aleh_load.cost_model.dyngroups.dmp regress/materialized.load.dyngroups.osql -o "quit;"
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
echo * aleh_load.cost_model.dyngroups.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
