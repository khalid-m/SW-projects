@echo off
if "%php_source%" == "" goto error
if "%php_bin%" == "" goto error

msdev ..\..\system\MVC\adll\adll.dsw /make
msdev amos\amos.dsw /make

goto end

:error

echo Please set variables PHP_SOURCE and PHP_BIN first!

:end