@echo off
IF NOT EXIST root.dmp call mkdmp.root

cd osql
..\aleh ../root.dmp < "master.cost_model.dyngroups.osql"
cd ..

IF NOT EXIST aleh_load.cost_model.dyngroups.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating image file for materialized ontology 
echo *  loading entire file with the dynamic group cost model
echo *  is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end
