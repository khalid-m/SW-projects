@echo off
rem Parameter 1 set => Test released version
set releasing=%1
pushd ..\bin
echo ----------------Installing----------------
rem call killall.cmd will kill mysql too
IF EXIST amos2.dmp del amos2.dmp
IF EXIST amoslib.lib del amoslib.lib
call install all
popd
IF NOT EXIST ..\bin\amos2.dmp GOTO fail
pushd ..\regress
echo ----------------Remote evaluation--------------------
alisp -L remoteeval.lsp

echo ----------------Remote scans--------------------
amos2 -L remotescan.lsp

echo ----------------Starting servers----------------
call startservers

echo ----------------Lisp kernel regression test----------------
call testlisp.cmd

echo ----------------Kernel regression test----------------
..\bin\amos2 -O testin.osql
popd
pushd ..\system\C\regress
call regress
popd

if "%mexi%"=="" goto no_mexi
echo ----------------Testing Save and Restore Mexima----
call testmex.cmd
echo ----------------Testing XTREE ---------------------
pushd ..\extenders\XTREE\regress
call regress.cmd
popd
echo ----------------Testing AQIT ---------------------
pushd ..\aqit\regress
call regress.cmd
popd

:no_mexi
echo ----------------Testing multicasting----------------
call multicast.cmd

echo ----------------Testing Java interfaces----------------
gmake -C ..\java test
pushd ..\wrappers

echo ----------------Testing wrappers----------------------
call test_wrappers.bat
popd

echo ----------------Testing SQLFront----------------
pushd ..\SQL
call test.cmd
popd

echo ----------------Testing Python embedding----------------
pushd ..\embeddings\python
call install.cmd
call test.cmd
popd

echo ----------------Shutting down servers----------------
..\bin\amos2 -O shutdown.osql

echo ---------------- lprint + lread  ----------------
call nbgtest.cmd

echo ----------------Testing complex scientific queries from ALEH-------------
pushd ..\aleh
call simpletest.cmd
popd

echo ----------------Testing Edutella------------------
pushd ..\embeddings\Edutella\regress
call edutest.cmd
popd

echo ----------------Testing SWARD------------------
pushd ..\SWARD\regress
call testmaster.cmd
popd

echo ----------------Testing SWATM ------------------
pushd ..\wrappers\TopicMap
call test.cmd
popd

echo ----------------Testing SARD------------------
pushd ..\sard\sard_new\regress
call testmaster.cmd
popd

echo -----------Testing SARD2-parsing SPARQL with URI objects--------
pushd ..\sard\SARD2\regress
call testmaster.cmd
popd

echo ---------------Testing SSDM-------------------
pushd ..\sqond
call testmaster.cmd
popd

echo ----------------Testing Datamining (legacy)------------------
pushd ..\applications\DataMining
call regress.cmd
popd

echo ----------------Testing Datamining: AmosMiner------------------
pushd ..\applications\DataMining\AmosMiner
call regress.cmd
popd

echo ----------------Testing SCSQ-LR ------------------
pushd ..\scsq\SCSQ-LR
call install.cmd
call test.cmd
popd

echo *********** end test of released system ************
IF NOT "%releasing%" == ""        goto end;

echo ---------------- BigWrapper ------------------
pushd ..\wrappers\bigtable
call test.cmd
popd

echo ----------------Testing SVALI ---------------------
pushd ..\validate
call test
popd

echo ----------------Testing validate lr-----------------
rem pushd ..\validate\lr
rem call install
rem call test
rem popd

echo ----------------Testing LOGDIR ---------------------
pushd ..\logdir
call test
popd

echo ----------------Testing Linear Road ------------------
pushd ..\scsq\lr
call test
popd

echo ----------------Testing CSS ------------------
pushd ..\scsq\css
call test
popd

echo ----------------Testing SCSQ ------------------
pushd ..\scsq\
call test
popd

echo ----------------Testing LR-EZGen ------------------
pushd ..\scsq\generator
call test
popd

echo ----------------Testing Vortex ------------------
pushd ..\vortex
call test.cmd
popd

echo ----------------Testing EPIC ------------------
pushd ..\DEBS2013
call install.cmd
call test.cmd
popd

echo ----------------Testing wsmed ------------------
pushd ..\wsmed
call regress
popd

goto end

:fail
echo **************************************************************************
echo * Failed to install Amos II
echo * Press a key to exit.
echo **************************************************************************
pause
goto end

:end

