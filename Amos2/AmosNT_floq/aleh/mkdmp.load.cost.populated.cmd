@echo off
IF NOT EXIST root.dmp call mkdmp.root

cd osql
..\aleh ../root.dmp < "master.cost.populated.osql"
cd ..
echo --- Be aware that cuts are not loaded in the created dump. 
echo --- Cuts queries should be loaded after database is populated.

IF NOT EXIST aleh_load.cost.populated.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating image file for materialized ontology 
echo *  with complete cost model loading entire 
echo * file is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end

