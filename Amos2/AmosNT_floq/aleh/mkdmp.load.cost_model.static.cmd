@echo off
IF NOT EXIST root.dmp call mkdmp.root

cd osql
..\aleh ../root.dmp < "master.cost_model.static.osql"
cd ..

IF NOT EXIST aleh_load.cost_model.static.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating image file for materialized ontology 
echo *  loading entire file with the static cost model
echo *  is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end
