@echo off
echo -------------- Testing streaming without ontology -----------------------

IF NOT EXIST %AMOS_HOME%\wrappers\ROOTWrap\ROOTWrap.exe GOTO root_failed
IF NOT EXIST aleh_basic.dmp GOTO dmp_failed

%AMOS_HOME%\wrappers\ROOTWrap\ROOTWrap.exe aleh_basic.dmp regress/basic.osql -o "quit;"
goto end

:root_failed
echo ****************************************
echo * ROOTWrap.exe does not exist
echo * Press any key
echo ****************************************
pause 
goto end

:dmp_failed
echo *****************************************************************************
echo * aleh_basic.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end