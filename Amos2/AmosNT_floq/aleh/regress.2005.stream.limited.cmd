@echo off
echo ------------------------ Cuts 2005 -----------------------
echo -------------- Testing streaming ontology with structs ---
echo -------------- no cost model ---
IF NOT EXIST ..\wrappers\ROOTWrap\ROOTWrap.exe GOTO rootwrap_failed
IF NOT EXIST aleh_stream.profiling.dmp GOTO dmp_failed
..\wrappers\ROOTWrap\ROOTWrap.exe aleh_stream.limited.dmp regress/cuts2005.stream.limited.osql -o "quit;"
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
