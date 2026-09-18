# Microsoft Developer Studio Project File - Name="amoslib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=amoslib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "amoslib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "amoslib.mak" CFG="amoslib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "amoslib - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "amoslib - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "amoslib - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /FD /c
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "amoslib - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "."
# PROP Intermediate_Dir "."
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /Z7 /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O2 /I "..\..\C" /I "..\include" /I "c:\PROGRAM FILES\DevStudio\VC\include" /D "WIN32" /D "_WINDOWS" /Fr /FD /c
# ADD BASE RSC /l 0x409
# ADD RSC /l 0x409
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"..\..\bin\amoslib.lib"

!ENDIF 

# Begin Target

# Name "amoslib - Win32 Release"
# Name "amoslib - Win32 Debug"
# Begin Source File

SOURCE=..\C\a_pca.c
# End Source File
# Begin Source File

SOURCE=..\C\a_time.c
# End Source File
# Begin Source File

SOURCE=..\..\C\a_time.h
# End Source File
# Begin Source File

SOURCE=..\C\aggops.c
# End Source File
# Begin Source File

SOURCE=..\..\C\alisp.h
# End Source File
# Begin Source File

SOURCE=..\include\amos.h
# End Source File
# Begin Source File

SOURCE=..\C\amosfns.c
# End Source File
# Begin Source File

SOURCE=..\include\amosfns.h
# End Source File
# Begin Source File

SOURCE=..\C\binary.c
# End Source File
# Begin Source File

SOURCE=..\include\binary.h
# End Source File
# Begin Source File

SOURCE=..\C\buffer.c
# End Source File
# Begin Source File

SOURCE=..\C\c0xdir.c
# End Source File
# Begin Source File

SOURCE=..\..\C\callin.h
# End Source File
# Begin Source File

SOURCE=..\..\C\callout.h
# End Source File
# Begin Source File

SOURCE=..\C\cinterf.c
# End Source File
# Begin Source File

SOURCE=..\C\comm.c
# End Source File
# Begin Source File

SOURCE=..\include\comm.h
# End Source File
# Begin Source File

SOURCE=..\C\commands.c
# End Source File
# Begin Source File

SOURCE=..\C\compl_fns.c
# End Source File
# Begin Source File

SOURCE=..\C\coroutine.c
# End Source File
# Begin Source File

SOURCE=..\include\coroutine.h
# End Source File
# Begin Source File

SOURCE=..\C\event_manager.c
# End Source File
# Begin Source File

SOURCE=..\C\expression.c
# End Source File
# Begin Source File

SOURCE=..\C\filefns.c
# End Source File
# Begin Source File

SOURCE=..\C\files.c
# End Source File
# Begin Source File

SOURCE=..\C\getopt.c
# End Source File
# Begin Source File

SOURCE=..\C\htbl.c
# End Source File
# Begin Source File

SOURCE=..\include\htbl.h
# End Source File
# Begin Source File

SOURCE=..\include\index.h
# End Source File
# Begin Source File

SOURCE=..\C\init.c
# End Source File
# Begin Source File

SOURCE=..\include\intstorage.h
# End Source File
# Begin Source File

SOURCE=..\include\kernel.h
# End Source File
# Begin Source File

SOURCE=..\C\language.c
# End Source File
# Begin Source File

SOURCE=..\..\C\language.h
# End Source File
# Begin Source File

SOURCE=..\C\lexSQL.c
# End Source File
# Begin Source File

SOURCE=..\C\lexyy.c
# End Source File
# Begin Source File

SOURCE=..\C\linh.c
# End Source File
# Begin Source File

SOURCE=..\C\lispfns.c
# End Source File
# Begin Source File

SOURCE=..\C\lock.c
# End Source File
# Begin Source File

SOURCE=..\C\lock.h
# End Source File
# Begin Source File

SOURCE=..\C\math_fns.c
# End Source File
# Begin Source File

SOURCE=..\C\mersenne.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_foreign.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_foreign.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_generic_api.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_generic_api.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_relation.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mex_relation.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexi.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexi.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexi_ff.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexi_ff.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexima.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexima.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexmeda.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexmeda.h
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexutilities.c
# End Source File
# Begin Source File

SOURCE=..\C\mexima\mexutilities.h
# End Source File
# Begin Source File

SOURCE=..\C\os_fns.c
# End Source File
# Begin Source File

SOURCE=..\C\parser_tab.c
# End Source File
# Begin Source File

SOURCE=..\C\RDF.c
# End Source File
# Begin Source File

SOURCE=..\C\scan.c
# End Source File
# Begin Source File

SOURCE=..\C\sql_parser_tab.c
# End Source File
# Begin Source File

SOURCE=..\C\sql_parser_tab.h
# End Source File
# Begin Source File

SOURCE=..\C\SQLParse.c
# End Source File
# Begin Source File

SOURCE=..\..\C\storage.h
# End Source File
# Begin Source File

SOURCE=..\C\storagetypes.c
# End Source File
# Begin Source File

SOURCE=..\include\storagetypes.h
# End Source File
# Begin Source File

SOURCE=..\C\strings.c
# End Source File
# Begin Source File

SOURCE=..\include\strings.h
# End Source File
# Begin Source File

SOURCE=..\C\text_fns.c
# End Source File
# Begin Source File

SOURCE=..\C\text_match.c
# End Source File
# Begin Source File

SOURCE=..\C\text_match.h
# End Source File
# Begin Source File

SOURCE=..\C\tls.c
# End Source File
# Begin Source File

SOURCE=..\C\top.c
# End Source File
# Begin Source File

SOURCE=..\C\typecheck.c
# End Source File
# Begin Source File

SOURCE=..\C\uri.c
# End Source File
# Begin Source File

SOURCE=..\C\winagg.c
# End Source File
# Begin Source File

SOURCE=..\C\wproctime.c
# End Source File
# Begin Source File

SOURCE=..\include\wproctime.h
# End Source File
# Begin Source File

SOURCE=..\C\wsalib.c
# End Source File
# Begin Source File

SOURCE=.\eval.obj
# End Source File
# Begin Source File

SOURCE=.\event_manager.obj
# End Source File
# Begin Source File

SOURCE=.\extfns.obj
# End Source File
# Begin Source File

SOURCE=.\fncall.obj
# End Source File
# Begin Source File

SOURCE=.\hist.obj
# End Source File
# Begin Source File

SOURCE=.\index.obj
# End Source File
# Begin Source File

SOURCE=.\libyywrap.obj
# End Source File
# Begin Source File

SOURCE=.\linh.obj
# End Source File
# Begin Source File

SOURCE=.\misc.obj
# End Source File
# Begin Source File

SOURCE=.\oid.obj
# End Source File
# Begin Source File

SOURCE=.\olog.obj
# End Source File
# Begin Source File

SOURCE=.\print.obj
# End Source File
# Begin Source File

SOURCE=.\read.obj
# End Source File
# Begin Source File

SOURCE=.\rel.obj
# End Source File
# Begin Source File

SOURCE=.\storage.obj
# End Source File
# Begin Source File

SOURCE=.\systemfns.obj
# End Source File
# Begin Source File

SOURCE=.\btree.obj
# End Source File
# End Target
# End Project
