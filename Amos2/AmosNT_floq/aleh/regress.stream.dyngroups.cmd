@echo off
echo -------------- Testing streaming ontology with structs ---
echo -------------- pofiled group cost model ---
IF NOT EXIST ..\wrappers\ROOTWrap\ROOTWrap.exe GOTO rootwrap_failed
IF NOT EXIST aleh_stream.dyngroups.dmp GOTO dmp_failed
..\wrappers\ROOTWrap\ROOTWrap.exe aleh_stream.dyngroups.dmp regress/stream.dyngroups.osql -o "quit;"
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
echo * aleh_stream.dyngroups.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
