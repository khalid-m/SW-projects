@echo off
REM ****************************************************************************
REM AMOS2
REM 
REM Author: (c) UDBL
REM $RCSfile: install.bat,v $
REM $Revision: 1.119 $ $Date: 2012/05/22 15:03:20 $
REM $State: Exp $ $Locker:  $
REM
REM Description: Installation script for Amos.
REM
REM ****************************************************************************

REM -- check for legal parameters --
IF "%1" == ""        goto top
IF "%1" == "nojava"    goto top
IF "%1" == "all"     goto top
IF "%1" == "help"    goto help
IF "%1" == "?"       goto help

echo Wrong installation parameter: %1
goto help

REM -- do the real thing --
:top

IF "%AMOS_HOME%"=="" GOTO noamoshome
cd "%AMOS_HOME%\bin"


IF EXIST amos2.dmp del amos2.dmp
IF EXIST amos2.dmp GOTO fail
IF EXIST alisp.dmp del alisp.dmp
IF EXIST alisp.dmp GOTO fail

echo **************************************************************************
echo * Creating amos2.exe and amoslib.lib 
echo **************************************************************************
if exist amoslib.lib del amoslib.lib
del amos2.dll
if exist amos2.dll goto amoslocked
del alisp.exe
if exist alisp.exe goto amoslocked
pushd ..\system\C
..\..\bin\gmake -f mkparsers.mak
if NOT EXIST sql_parser_tab.c GOTO nobison
popd
del amos2.dll
pushd ..\system\MVC
call compile.cmd
popd

REM ===========================================================================
REM AMOS image creation section
REM ===========================================================================

set bigintegrator=1
IF "%1" == ""        goto base_install      REM-- default
IF "%1" == "all"        goto base_install      REM-- default
IF "%1" == "nojava"    goto base_install

goto end

:base_install
set mexi=1
if "%mexi%"=="" goto no_mexi

echo **************************************************************************
echo * Installing mexima extenders
echo **************************************************************************

IF EXIST bt.dll del bt.dll
pushd  ..\extenders\BTREE\MVC\EXTENDER
msdev btmexiextender.dsp /MAKE "btmexiextender - Win32 Release" /CLEAN
msdev btmexiextender.dsp /MAKE "btmexiextender - Win32 Release" /NORECURSE /REBUILD
popd

IF EXIST xt.dll del xt.dll
pushd  ..\extenders\XTREE\MVC\EXTENDER
msdev xtmexiextender.dsp /MAKE "xtmexiextender - Win32 Release" /CLEAN
msdev xtmexiextender.dsp /MAKE "xtmexiextender - Win32 Release" /NORECURSE /REBUILD
popd

:no_mexi
echo **************************************************************************
echo * Creating amos2.dmp
echo **************************************************************************
gmake amos2.dmp
goto mvc

:help
echo **************************************************************************
echo * Usage: install [option]
echo * option = nojava      : do not create javaamos
echo * option = {help or ?} : display this message (default)
echo **************************************************************************
goto end

:fail
echo **************************************************************************
echo * Unable to create amos2.dmp
echo **************************************************************************
pause
goto end

:amoslocked
echo **************************************************************************
echo * Unable to replace amos2.dll or javaamos
echo * Is it locked by some program?
echo **************************************************************************
pause
goto end


:nobison
cd ..\..\bin
echo **************************************************************************
echo * Unable to create SQL parser
echo * Did you install bison and flex correctly?
echo **************************************************************************
pause
goto end

:java_compile_fail
echo **************************************************************************
echo * Java compilation failed
echo **************************************************************************
pause
goto end

:java_amos_fail
echo **************************************************************************
echo * Unable to create JavaAmos.dll
echo * Possible reasons:
echo * - Your JDK environment variable is not set to point to a JDK installation
echo * - Your JDK environment variable points to an incompatible JDK version
echo **************************************************************************
pause
goto end

:nojdk
echo **************************************************************************
echo * Please set environment variable JDK to point to your 
echo * Java JDK home directory
echo **************************************************************************
pause
goto end

:wrong_jdk
echo **************************************************************************
echo * The file JVM.LIB could not be created.
echo * Most likely your JDK environment variable doesn't point to a JDK installation
echo **************************************************************************
pause
goto end

:noamoshome
echo **************************************************************************
echo * Set environment variable AMOS_HOME to point to your AmosNT directory
echo **************************************************************************
pause
goto end

:mvc
if NOT EXIST amos2.dmp GOTO InstallFailed

echo **************************************************************************
echo * Creating Python extender
echo **************************************************************************
pushd ..\embeddings\Python
call install.cmd
popd

echo **************************************************************************
echo * Creating SSDM extender
echo **************************************************************************
pushd ..\SQoND
call install.cmd
popd
if "%1%"=="nojava" GOTO end

echo **************************************************************************
echo * Creating JavaAmos.dll
echo **************************************************************************

del javaamos.dll
if exist javaamos.dll goto amoslocked

IF "%JDK%"=="" GOTO nojdk
set JVM=

REM -- Up to JDK 1.3 the JVM is under 'classic' or 'hotspot'
IF EXIST "%JDK%\jre\bin\classic\jvm.dll" set JVM=%JDK%\jre\bin\classic

REM -- From JDK 1.4 the JVM is under 'client' or 'server'
IF EXIST "%JDK%\jre\bin\client\jvm.dll" set JVM=%JDK%\jre\bin\client

REM -- From JDK 1.5 there is no jre any more
IF EXIST "%JDK%\bin\client\jvm.dll" set JVM=%JDK%\bin\client

REM -- From JDK 1.6
IF EXIST "%JDK%\jre\bin\server\jvm.dll" set JVM=%JDK%\bin\client

IF "%JVM%"=="" GOTO wrong_jdk

pushd ..\system\MVC
msdev JavaAmos.dsw /make
popd

echo **************************************************************************
echo * Creating javaamos.jar
echo **************************************************************************

del javaamos.jar
gmake -C ..\java
if NOT EXIST javaamos.jar GOTO java_compile_fail

pushd ..\wrappers\jdbc
gmake 
popd

if NOT EXIST javaamos.jar GOTO java_amos_fail
IF NOT EXIST JavaAmos.dll GOTO java_amos_fail

if NOT "%CLASSPATH%" == "" GOTO end

echo set CLASSPATH set to 
echo %AMOS_HOME%/bin/javaamos.jar;.;%AMOS_HOME%/jarlib/mysql-connector-java-5.1.6-bin.jar
pause

GOTO end

:InstallFailed
echo **************************************************************************
echo * Installation of Amos II failed.
echo * Look for errors in C and Java compilations and linkings 
echo **************************************************************************
pause
goto end

:MVCFailed
echo **************************************************************************
echo * Compilation of Amos II using Visual Studio C++ failed
echo * Did you install Visual Studio C++ 6.0?
echo * Make sure PATH includes path to msdev.exe and directories of all library dlls
echo **************************************************************************
pause
goto end

:end
echo Done.
