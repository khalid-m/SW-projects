@echo off
pushd %AMOS_HOME%\wrappers\ROOTWrap
del ROOTWrap.exe
del ROOTWrap.dmp
del amain.obj
del structs.obj
call compile
IF NOT EXIST ROOTWrap.exe GOTO rootwrap_failed
call mkdmp
IF NOT EXIST rootwrap.dmp GOTO rootwrap_failed
popd

del current.dmp

call mkdmp.current

IF NOT EXIST current.dmp GOTO dmp_failed

goto end

:dmp_failed
echo *****************************************************************************
echo * Creating image file for current aleh approach is failed
echo 
goto failed

:rootwrap_failed
popd
echo *****************************************************************************
echo * ROOT wrapper installation is failed
echo 
goto failed

:failed
echo ****************************************
echo * Test master is failed
echo * Press any key
echo ****************************************
pause
goto end

:end
