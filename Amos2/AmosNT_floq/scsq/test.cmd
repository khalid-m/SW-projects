@echo off
echo ------------------------------------------------------------
echo Generating SCSQ binaries
call compile
if NOT EXIST ..\bin\scsq.exe GOTO MSDEVfailed
call mkdmp
echo ------------------------------------------------------------

pushd proctime
if exist ret del ret
if exist retout del retout
if exist retout.csv del retout.csv
if exist pr* del pr*
popd
pushd data
if exist writefile-test del writefile-test
if exist writefiles-test* del writefiles-test*
popd

start scsq.exe -ns
scsq -O regress/master.osql -O regress/scsqlregress.osql -O regress/bgcoregress.osql

goto end

:MSDEVfailed
echo **************************************************************************
echo * Compilation of SCSQ failed. 
echo * Is Visual Studio C++ 6.0 installed?
echo * 
echo * Make sure PATH includes path to msdev and dirs of all library dlls
echo * Press a key to exit.
echo **************************************************************************
pause
goto end

:end
if exist data\bin0 del data\bin0
popd
