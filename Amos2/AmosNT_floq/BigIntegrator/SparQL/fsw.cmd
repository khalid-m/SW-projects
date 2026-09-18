@echo off
IF "%AMOS_HOME%"=="" GOTO setamos
call checkpath
java -cp %AMOS_HOME%/bin/javaamos.jar;%AMOS_HOME%/BigIntegrator/SparQL/src/Java;. JavaAMOS fsw.dmp %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO done
:setamos
echo Please set AMOS_HOME
:done
