@echo off
IF "%AMOS_HOME%"=="" GOTO setamos
call checkpath
::java -cp %AMOS_HOME%/bin/javaamos.jar;. JavaAMOS -L sparql.lsp -o "save 'fsw.dmp'; quit;"
::javaamos -o "loadsystem('src/AmosQL','master.amosql'); save 'fsw.dmp'; quit;" 
::call javaamos -O master.amosql -o "save 'fsw.dmp'; quit;"
::java -cp %AMOS_HOME%/bin/javaamos.jar;. JavaAMOS -L src/Lisp/master.lsp -o "save ::'fsw.dmp'; quit;"
java -cp %AMOS_HOME%/bin/javaamos.jar;%AMOS_HOME%/BigIntegrator/SparQL/src/Java;. JavaAMOS -L src/Lisp/master.lsp -o "save 'fsw.dmp'; quit;" 
GOTO done
:setamos
echo Please set AMOS_HOME
:done
