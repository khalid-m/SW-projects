@echo off
echo ---------- Testing materialized ontology with aggregate cost model, loading entire file ---
IF NOT EXIST aleh.exe GOTO aleh_failed
IF NOT EXIST aleh_load.cost.populated.dmp GOTO dmp_failed
aleh aleh_load.cost.populated.dmp regress/materialized.load.cost.populated.osql -o "quit;"
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
echo * aleh_load.cost.populated.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end