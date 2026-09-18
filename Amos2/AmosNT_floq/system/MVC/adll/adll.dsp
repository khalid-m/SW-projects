# Microsoft Developer Studio Project File - Name="adll" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=adll - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "adll.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "adll.mak" CFG="adll - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "adll - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "adll - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "adll - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "ADLL_EXPORTS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "ADLL_EXPORTS" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x41d /d "NDEBUG"
# ADD RSC /l 0x41d /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "adll - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ""
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "ADLL_EXPORTS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O2 /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_DLL" /D "KERNEL_DLL" /FR /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x41d /d "_DEBUG"
# ADD RSC /l 0x41d /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /dll /incremental:no /debug /machine:I386 /out:"..\..\..\bin\amos2.dll" /implib:"..\..\..\bin\amos2.lib" /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "adll - Win32 Release"
# Name "adll - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\..\C\a_pca.c
# End Source File
# Begin Source File

SOURCE=..\..\C\a_time.c
# End Source File
# Begin Source File

SOURCE=.\adll.c
# End Source File
# Begin Source File

SOURCE=..\..\C\aggops.c
# End Source File
# Begin Source File

SOURCE=..\..\C\amosfns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\binary.c
# End Source File
# Begin Source File

SOURCE=..\..\C\buffer.c
# End Source File
# Begin Source File

SOURCE=..\..\C\c0xdir.c
# End Source File
# Begin Source File

SOURCE=..\..\C\cinterf.c
# End Source File
# Begin Source File

SOURCE=..\..\C\comm.c
# End Source File
# Begin Source File

SOURCE=..\..\C\commands.c
# End Source File
# Begin Source File

SOURCE=..\..\C\compl_fns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\coroutine.c
# End Source File
# Begin Source File

SOURCE=..\..\C\CSV.c
# End Source File
# Begin Source File

SOURCE=..\..\C\event_manager.c
# End Source File
# Begin Source File

SOURCE=..\..\C\expression.c
# End Source File
# Begin Source File

SOURCE=..\..\C\extender.c
# End Source File
# Begin Source File

SOURCE=..\..\C\filefns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\files.c
# End Source File
# Begin Source File

SOURCE=..\..\C\getopt.c
# End Source File
# Begin Source File

SOURCE=..\..\C\htbl.c
# End Source File
# Begin Source File

SOURCE=..\..\C\init.c
# End Source File
# Begin Source File

SOURCE=..\..\C\language.c
# End Source File
# Begin Source File

SOURCE=..\..\C\lexSQL.c
# End Source File
# Begin Source File

SOURCE=..\..\C\lexyy.c
# End Source File
# Begin Source File

SOURCE=..\..\C\linh.c
# End Source File
# Begin Source File

SOURCE=..\..\C\lispfns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\lock.c
# End Source File
# Begin Source File

SOURCE=..\..\C\math_fns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mersenne.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_foreign.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_generic_api.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_relation.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexi.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexi_ff.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexima.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexmeda.c
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexutilities.c
# End Source File
# Begin Source File

SOURCE=..\..\C\nbprint.c
# End Source File
# Begin Source File

SOURCE=..\..\C\os_fns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\parser_tab.c
# End Source File
# Begin Source File

SOURCE=..\..\C\RDF.c
# End Source File
# Begin Source File

SOURCE=..\..\C\scan.c
# End Source File
# Begin Source File

SOURCE=..\..\C\scan_remote.c
# End Source File
# Begin Source File

SOURCE=..\..\C\sql_parser_tab.c
# End Source File
# Begin Source File

SOURCE=..\..\C\startupdirectory.c
# End Source File
# Begin Source File

SOURCE=..\..\C\storagetypes.c
# End Source File
# Begin Source File

SOURCE=..\..\C\strings.c
# End Source File
# Begin Source File

SOURCE=..\..\C\text_fns.c
# End Source File
# Begin Source File

SOURCE=..\..\C\text_match.c
# End Source File
# Begin Source File

SOURCE=..\..\C\threadbarrier.c
# End Source File
# Begin Source File

SOURCE=..\..\C\tls.c
# End Source File
# Begin Source File

SOURCE=..\..\C\top.c
# End Source File
# Begin Source File

SOURCE=..\..\C\typecheck.c
# End Source File
# Begin Source File

SOURCE=..\..\C\uri.c
# End Source File
# Begin Source File

SOURCE=..\..\C\winagg.c
# End Source File
# Begin Source File

SOURCE=..\..\C\wproctime.c
# End Source File
# Begin Source File

SOURCE=..\..\C\wsalib.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\..\C\a_time.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\alisp.h
# End Source File
# Begin Source File

SOURCE=..\..\include\amos.h
# End Source File
# Begin Source File

SOURCE=..\..\include\binary.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\callin.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\callout.h
# End Source File
# Begin Source File

SOURCE=..\..\include\comm.h
# End Source File
# Begin Source File

SOURCE=..\..\C\commands.h
# End Source File
# Begin Source File

SOURCE=..\..\include\coroutine.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\environ.h
# End Source File
# Begin Source File

SOURCE=..\..\C\filefns.h
# End Source File
# Begin Source File

SOURCE=..\..\C\getopt.h
# End Source File
# Begin Source File

SOURCE=..\..\include\htbl.h
# End Source File
# Begin Source File

SOURCE=..\..\include\index.h
# End Source File
# Begin Source File

SOURCE=..\..\include\intstorage.h
# End Source File
# Begin Source File

SOURCE=..\..\include\kernel.h
# End Source File
# Begin Source File

SOURCE=..\..\include\lock.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_foreign.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_generic_api.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mex_relation.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexi.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexi_ff.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexima.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexmeda.h
# End Source File
# Begin Source File

SOURCE=..\..\C\mexima\mexutilities.h
# End Source File
# Begin Source File

SOURCE=..\..\C\sql_parser_tab.h
# End Source File
# Begin Source File

SOURCE=..\..\..\C\storage.h
# End Source File
# Begin Source File

SOURCE=..\..\include\storagetypes.h
# End Source File
# Begin Source File

SOURCE=..\..\include\strings.h
# End Source File
# Begin Source File

SOURCE=..\..\C\text_match.h
# End Source File
# Begin Source File

SOURCE=..\..\include\threadbarrier.h
# End Source File
# Begin Source File

SOURCE=..\..\include\wproctime.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=..\..\C\parser.y
# End Source File
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# Begin Source File

SOURCE=..\..\C\scanner.l
# End Source File
# Begin Source File

SOURCE=..\eval.obj
# End Source File
# Begin Source File

SOURCE=..\btree.obj
# End Source File
# Begin Source File

SOURCE=..\extfns.obj
# End Source File
# Begin Source File

SOURCE=..\fncall.obj
# End Source File
# Begin Source File

SOURCE=..\hist.obj
# End Source File
# Begin Source File

SOURCE=..\index.obj
# End Source File
# Begin Source File

SOURCE=..\libyywrap.obj
# End Source File
# Begin Source File

SOURCE=..\misc.obj
# End Source File
# Begin Source File

SOURCE=..\oid.obj
# End Source File
# Begin Source File

SOURCE=..\olog.obj
# End Source File
# Begin Source File

SOURCE=..\print.obj
# End Source File
# Begin Source File

SOURCE=..\read.obj
# End Source File
# Begin Source File

SOURCE=..\rel.obj
# End Source File
# Begin Source File

SOURCE=..\storage.obj
# End Source File
# Begin Source File

SOURCE=..\systemfns.obj
# End Source File
# End Target
# End Project
