@echo off
IF NOT EXIST root.dmp call mkdmp.root

cd osql
..\aleh ../root.dmp < "master.osql"
cd ..

IF NOT EXIST aleh_load.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating image file for materialized ontology 
echo *  loading entire file is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end
