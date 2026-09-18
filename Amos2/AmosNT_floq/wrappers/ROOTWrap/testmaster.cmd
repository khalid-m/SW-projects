@echo off
echo -------------------------- ROOT wrapper test master --------------------------
IF "%ROOTSYS%" NEQ "" goto rootsysok 
echo Environment variable ROOTSYS not set.
echo Set it to home of ROOT system!
goto end
:rootsysok
del ROOTWrap.exe
del ROOTWrap.dmp
del amain.obj
del aleh_udfs.obj
del structs.obj
call compile
IF NOT EXIST ROOTWrap.exe GOTO end
call mkdmp
IF NOT EXIST rootwrap.dmp GOTO dmp_failed
call regress
goto end

:dmp_failed
echo ****************************************
echo * Creating image for ROOT wrapper failed
echo * Press any key to exit
echo ****************************************
pause
goto end

:end
