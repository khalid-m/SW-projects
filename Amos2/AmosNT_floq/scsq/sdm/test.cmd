@echo off
REM ***************************************************************************
REM AMOS2
REM
REM Author: (c) 2009 Gyozo gidofalvi UDBL
REM $RCSfile: test.cmd,v $
REM $Revision: 1.1 $ $Date: 2009/03/05 18:18:45 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Script to perform regession testing of SDM
REM
REM ***************************************************************************

scsq.exe sdm.dmp -O "regress/test.osql" -o "quit;"
