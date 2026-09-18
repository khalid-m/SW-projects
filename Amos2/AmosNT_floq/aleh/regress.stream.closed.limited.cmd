@echo off
echo -------------- Testing streaming ontology with structs ---
echo -------------- closed discjunction, no cost model (MAN) ---
IF NOT EXIST ..\wrappers\ROOTWrap\ROOTWrap.exe GOTO rootwrap_failed
IF NOT EXIST aleh_stream.limited.dmp GOTO dmp_failed
..\wrappers\ROOTWrap\ROOTWrap.exe aleh_stream.limited.dmp regress/stream.closed.limited.osql -o "quit;"
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
echo * aleh_stream.limited.dmp does not exist
echo * Press any key
echo *****************************************************************************
pause 
goto end

:end
