@echo off
:st3
call setup.cmd
call compile.cmd
call mkdmp.cmd
echo --------------------------------------------------
echo Testing ff_applyp...............
echo --------------------------------------------------
set /a count3=0
for /r %AMOS_HOME%wsmed %%X in (*.class,*.dmp) do (set /a count3+=1)
if %count3% lss 13 (goto :st3) 

call java JavaAMOS wsmed.dmp -O src/amosql/testcoroutine1.amosql

call amos2 -O src/amosql/testcoroutine4.amosql

exit /B











