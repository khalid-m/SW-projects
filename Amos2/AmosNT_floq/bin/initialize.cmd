@echo off
IF EXIST amos2.dmp GOTO end

gmake amos2.dmp

:end
echo [Amos II initialized OK]