# Microsoft Developer Studio Project File - Name="ODBCAmos" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=ODBCAmos - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "ODBCAmos.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ODBCAmos.mak" CFG="ODBCAmos - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ODBCAmos - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "ODBCAmos - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "ODBCAmos - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "output"
# PROP Intermediate_Dir "intermed"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /Gi /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /FR /YX"PrecompiledHeaders.h" /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /machine:I386 /nodefaultlib:"libcmt.lib libc.lib" /nodefaultlib:"libcmt.lib" /nodefaultlib:"libc.lib" /out:"../../bin/ODBCAmos.exe"
# SUBTRACT LINK32 /nodefaultlib

!ELSEIF  "$(CFG)" == "ODBCAmos - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "output"
# PROP Intermediate_Dir "intermed"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /Gm /Gi /Zi /Od /I "../../AmosNT/C" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /FR /YX"PrecompiledHeaders.h" /FD /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libc.lib" /out:"../bin/ODBCAmos.exe" /pdbtype:sept
# SUBTRACT LINK32 /nodefaultlib

!ENDIF 

# Begin Target

# Name "ODBCAmos - Win32 Release"
# Name "ODBCAmos - Win32 Debug"
# Begin Source File

SOURCE=.\Bindcols.c
# End Source File
# Begin Source File

SOURCE=.\Conknown.c
# End Source File
# Begin Source File

SOURCE=.\Desccol.c
# End Source File
# Begin Source File

SOURCE=.\DSNList.c
# End Source File
# Begin Source File

SOURCE=.\ODBCfns.c
# End Source File
# Begin Source File

SOURCE=.\ODBCMain.c
# End Source File
# Begin Source File

SOURCE=.\Queue.c
# End Source File
# Begin Source File

SOURCE=.\Showerr.c
# End Source File
# Begin Source File

SOURCE=..\bin\amoslib.lib
# End Source File
# End Target
# End Project
