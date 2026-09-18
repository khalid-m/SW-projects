@echo off
IF "%AMOS_HOME%"=="" GOTO setamos
call checkpath
java -cp %AMOS_HOME%/bin/javaamos.jar;. JavaAMOS -L sparql.lsp -o "save 'fsw.dmp'; quit;"
GOTO done
:setamos
echo Please set AMOS_HOME
:done
