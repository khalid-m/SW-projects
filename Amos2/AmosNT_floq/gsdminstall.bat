@echo off
REM ***************************************************************************
REM AMOS2, GSDM
REM 
REM Author: (c) UDBL, MI
REM $RCSfile: gsdminstall.bat,v $
REM $Revision: 1.1 $ $Date: 2005/12/19 17:27:16 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Installation script for GSDM under Windows.
REM
REM ****************************************************************************
echo ********* Compiling UDP functionality.
cd %AMOS_HOME%\gsdm\C
make -f broadcaster.mak
copy broadcaster.exe ..\..\bin\bcast.exe

echo ********* Creating GSDM working nodes.
cd ..
bcast -O createdmp.osql
echo ********* Creating GSDM coordinator.
bcast gsdm.dmp -O createcoord.osql 
