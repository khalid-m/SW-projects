@echo off

aleh -i ../lsp/init.lsp -o "save 'root.dmp'; quit;"

IF NOT EXIST root.dmp GOTO failed

goto end

:failed
echo ****************************************
echo * Creating basic image file for 
echo *  loading entire file is failed.
echo * Press any key
echo ****************************************
pause
goto end

:end
