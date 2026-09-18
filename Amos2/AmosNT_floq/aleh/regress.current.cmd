@echo off
echo -------------- Current working version ---
echo -------------- Testing streaming ontology with structs ---
echo -------------- Wrapper returns event structs ---
IF NOT EXIST ..\wrappers\ROOTWrap\ROOTWrap.exe GOTO rootwrap_failed
call mkdmp.current
IF NOT EXIST current.dmp GOTO dmp_failed
IF NOT EXIST current.limited.dmp GOTO dmp_failed
..\wrappers\ROOTWrap\ROOTWrap.exe current.dmp regress/stream.structs.2005.osql -o "quit;"
..\wrappers\ROOTWrap\ROOTWrap.exe current.basic.dmp regress/stream.structs.limited.2005.osql -o "quit;"
..\wrappers\ROOTWrap\ROOTWrap.exe current.dmp regress/stream.structs.osql -o "quit;"
..\wrappers\ROOTWrap\ROOTWrap.exe current.limited.dmp regress/stream.structs.limited.osql -o "quit;"
goto end

:rootwrap_failed
echo ****************************************
echo * ROOTWrap.exe does not exist
echo * Press any key
echo ****************************************
pause 
goto end

:dmp_failed
echo *****************************************************************************
echo * dmp for current version does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
