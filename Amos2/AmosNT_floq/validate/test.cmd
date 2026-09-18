@echo off
echo ------------------------------------------------------------
echo Generating SVALI binaries
call compile
if NOT EXIST ..\bin\svali.exe GOTO MSDEVfailed
call mkdmp
echo ------------------------------------------------------------

svali svali -o "loadsystem('regress', 'test_validate.osql');"
start svali -ns
svali -O regress/joinregress.osql

goto end

:MSDEVfailed
echo **************************************************************************
echo * Compilation of svali failed. 
echo * Is Visual Studio C++ 6.0 installed?
echo * Is scsq installed properly?
echo * Press a key to exit.
echo **************************************************************************
pause
goto end

:end