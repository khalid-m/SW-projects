# Microsoft Developer Studio Project File - Name="scsqlib" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=scsqlib - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "scsqlib.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "scsqlib.mak" CFG="scsqlib - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "scsqlib - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "scsqlib - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "scsqlib - Win32 Release"

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

!ELSEIF  "$(CFG)" == "scsqlib - Win32 Debug"

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
# ADD CPP /nologo /MD /W3 /GX /O2 /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system/include" /I "$(AMOS_HOME)\scsq/include" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /FR /YX /FD /c
# ADD BASE RSC /l 0x41d /d "_DEBUG"
# ADD RSC /l 0x41d /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo /out:"..\..\bin\scsqlib.lib"

!ENDIF 

# Begin Target

# Name "scsqlib - Win32 Release"
# Name "scsqlib - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\C\a_fft.c
# End Source File
# Begin Source File

SOURCE=..\C\bgcommon.c
# End Source File
# Begin Source File

SOURCE=..\C\bgextract.c
# End Source File
# Begin Source File

SOURCE=..\C\bgsubmit.c
# End Source File
# Begin Source File

SOURCE=..\C\bitwise.c
# End Source File
# Begin Source File

SOURCE=..\C\extract.c
# End Source File
# Begin Source File

SOURCE=..\C\fileaccess.c
# End Source File
# Begin Source File

SOURCE=..\C\fourier.c
# End Source File
# Begin Source File

SOURCE=..\C\ft.c
# End Source File
# Begin Source File

SOURCE=..\C\init_scsq.c
# End Source File
# Begin Source File

SOURCE=..\C\lofardata.c
# End Source File
# Begin Source File

SOURCE=..\C\lrmultiply.c
# End Source File
# Begin Source File

SOURCE=..\C\mathfns.c
# End Source File
# Begin Source File

SOURCE=..\C\multiarray.c
# End Source File
# Begin Source File

SOURCE=..\C\numarray.c
# End Source File
# Begin Source File

SOURCE=..\C\port.c
# End Source File
# Begin Source File

SOURCE=..\C\realfft.c
# End Source File
# Begin Source File

SOURCE=..\C\sproc.c
# End Source File
# Begin Source File

SOURCE=..\C\swin.c
# End Source File
# Begin Source File

SOURCE=..\C\twinagg.c
# End Source File
# Begin Source File

SOURCE=..\C\udp_src.c
# End Source File
# Begin Source File

SOURCE=..\C\udpq.c

!IF  "$(CFG)" == "scsqlib - Win32 Release"

!ELSEIF  "$(CFG)" == "scsqlib - Win32 Debug"

# ADD CPP /O2

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\C\w.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\include\a_fft.h
# End Source File
# Begin Source File

SOURCE=..\include\bgcommon.h
# End Source File
# Begin Source File

SOURCE=..\include\bgextract.h
# End Source File
# Begin Source File

SOURCE=..\include\bgsubmit.h
# End Source File
# Begin Source File

SOURCE=..\include\bitwise.h
# End Source File
# Begin Source File

SOURCE=..\include\extract.h
# End Source File
# Begin Source File

SOURCE=..\include\fftcomplex.h
# End Source File
# Begin Source File

SOURCE=..\include\fileaccess.h
# End Source File
# Begin Source File

SOURCE=..\include\mathfns.h
# End Source File
# Begin Source File

SOURCE=..\include\numarray.h
# End Source File
# Begin Source File

SOURCE=..\include\port.h
# End Source File
# Begin Source File

SOURCE=..\include\sproc.h
# End Source File
# Begin Source File

SOURCE=..\include\swin.h
# End Source File
# Begin Source File

SOURCE=..\include\twinagg.h
# End Source File
# Begin Source File

SOURCE=..\include\udp_src.h
# End Source File
# Begin Source File

SOURCE=..\include\udpq.h
# End Source File
# Begin Source File

SOURCE=..\include\w.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\bin\amos2.lib
# End Source File
# End Target
# End Project
