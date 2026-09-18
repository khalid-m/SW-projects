@echo off
REM ***************************************************************************
REM AMOS2
REM
REM Author: (c) 2009 Gyozo Gidofalvi UDBL
REM $RCSfile: install.cmd,v $
REM $Revision: 1.1 $ $Date: 2009/03/05 18:18:45 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Script to install SDM
REM
REM ***************************************************************************

pushd ..
call install
popd
..\..\bin\scsq.exe -i ..\..\lsp\init.lsp -o "loadsystem('../osql','sc.osql'); loadsystem('src','master.osql'); save '../../bin/sdm.dmp'; quit;"
