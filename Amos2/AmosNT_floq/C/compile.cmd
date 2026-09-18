@echo off
REM ****************************************************************************
REM AMOS2
REM 
REM Author: (c) UDBL
REM $RCSfile: compile.cmd,v $
REM 
REM
REM Compile C demo programs (Borland) and make callout.dmp
REM
REM ***************************************************************************

make -f demo.mak
make -f callout.mak
make -f remote.mak
make -f testcpp.mak
callout ../bin/amos2.dmp callout.amosql

