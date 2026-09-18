# Microsoft Developer Studio Project File - Name="vsqlib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=vsqlib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "vsqlib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "vsqlib.mak" CFG="vsqlib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "vsqlib - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "vsqlib - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "vsqlib - Win32 Release"

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
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD BASE RSC /l 0x41d /d "NDEBUG"
# ADD RSC /l 0x41d /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "vsqlib - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gi /GX /Zd /O2 /I "." /I "..\include" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system/include" /I "$(AMOS_HOME)\scsq\include" /I "$(LABVIEW_HOME)\cintools" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /FR /YX /FD /c
# ADD BASE RSC /l 0x41d /d "_DEBUG"
# ADD RSC /l 0x41d /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"vsqlib.lib"

!ENDIF 

# Begin Target

# Name "vsqlib - Win32 Release"
# Name "vsqlib - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\C\buildtuple.c
# End Source File
# Begin Source File

SOURCE=..\C\fixstream.c
# End Source File
# Begin Source File

SOURCE=..\C\init_vsq.c
# End Source File
# Begin Source File

SOURCE=..\C\parsetypes.c
# End Source File
# Begin Source File

SOURCE=..\..\system\C\strings.c
# End Source File
# Begin Source File

SOURCE=..\..\system\C\threadbarrier.c
# End Source File
# Begin Source File

SOURCE=..\C\vi.c
# End Source File
# Begin Source File

SOURCE=..\C\visualize.c
# End Source File
# Begin Source File

SOURCE=..\C\visualize_stream.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\include\buildtuple.h
# End Source File
# Begin Source File

SOURCE=..\include\fixstream.h
# End Source File
# Begin Source File

SOURCE=..\include\init_vsq.h
# End Source File
# Begin Source File

SOURCE=..\include\parsetypes.h
# End Source File
# Begin Source File

SOURCE=..\..\system\include\strings.h
# End Source File
# Begin Source File

SOURCE=..\..\system\include\threadbarrier.h
# End Source File
# Begin Source File

SOURCE=..\include\vi.h
# End Source File
# Begin Source File

SOURCE=..\include\visualize.h
# End Source File
# Begin Source File

SOURCE=..\include\visualize_stream.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\bin\scsqlib.lib
# End Source File
# Begin Source File

SOURCE=.\vsq_labview.lib
# End Source File
# End Target
# End Project
