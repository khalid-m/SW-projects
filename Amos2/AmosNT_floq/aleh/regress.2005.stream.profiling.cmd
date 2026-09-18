@echo off
echo -------------- Testing streaming ontology with structs ---
echo -------------- closed discjunction, dynamic pofiling ---
IF NOT EXIST ..\wrappers\ROOTWrap\ROOTWrap.exe GOTO rootwrap_failed
IF NOT EXIST aleh_stream.profiling.dmp GOTO dmp_failed
..\wrappers\ROOTWrap\ROOTWrap.exe aleh_stream.profiling.dmp regress/cuts2005.stream.profiling.osql -o "quit;"
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
echo * aleh_stream.closed.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
