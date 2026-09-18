@echo off
REM ****************************************************************************
REM AMOS2
REM 
REM Author: (c) UDBL
REM $RCSfile: install.bat,v $
REM $Revision: 1.1 $ $Date: 2013/08/12 10:33:26 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Installation script for Amos.
REM
REM ****************************************************************************


IF not EXIST ..\java\classdir mkdir ..\java\classdir

gmake -C ..\java
if NOT EXIST ..\java\lib\purejavaclient.jar GOTO java_compile_fail

GOTO end

:java_compile_fail
echo **************************************************************************
echo * Jar library is not created...
echo **************************************************************************
pause
goto end

:end
echo **************************************************************************
echo * The installations has been done successfully.
echo **************************************************************************
pause
echo Done.
