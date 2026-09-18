# Microsoft Developer Studio Project File - Name="amos2" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=amos2 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "amos2.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "amos2.mak" CFG="amos2 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "amos2 - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "amos2 - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "amos2 - Win32 Release With Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "amos2 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ""
# PROP Intermediate_Dir ""
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x804 /d "NDEBUG"
# ADD RSC /l 0x804 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib amos2.lib /nologo /dll /pdb:"../bin/amos2.pdb" /machine:I386 /out:"../bin/amos2.pyd" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /libpath:""..\..\..\C""
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "amos2 - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ""
# PROP Intermediate_Dir ""
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x804 /d "_DEBUG"
# ADD RSC /l 0x804 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib amos2.lib /nologo /dll /pdb:"../bin/amos2_d.pdb" /debug /machine:I386 /nodefaultlib:"msvcrt.lib" /out:"../bin/amos2_d.pyd" /pdbtype:sept /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /libpath:"$(AMOS_HOME)\bin" /verbose:lib
# SUBTRACT LINK32 /pdb:none /incremental:no

!ELSEIF  "$(CFG)" == "amos2 - Win32 Release With Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "amos2___Win32_Release_With_Debug"
# PROP BASE Intermediate_Dir "amos2___Win32_Release_With_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "amos2___Win32_Release_With_Debug"
# PROP Intermediate_Dir "amos2___Win32_Release_With_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /FR /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\callout\include" /D "WIN32" /D "DEBUG" /D "_CONSOLE" /D "_MBCS" /D "_USRDLL" /D "PYTHONDLL_EXPORTS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x804 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib amos2.lib /nologo /dll /pdb:"../bin/amos2.pdb" /machine:I386 /out:"../bin/amos2.pyd" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /libpath:""..\..\..\C""
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Ws2_32.lib amos2.lib /nologo /dll /incremental:yes /debug /machine:I386 /out:"../bin/amos2.pyd" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\bin" /libpath:"$(AMOS_HOME)\embeddings\Python\callout\libs" /libpath:""..\..\..\C""
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "amos2 - Win32 Release"
# Name "amos2 - Win32 Debug"
# Name "amos2 - Win32 Release With Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\C\amosmodule.c
# End Source File
# Begin Source File

SOURCE=..\C\pyiter.c
# End Source File
# Begin Source File

SOURCE=..\C\pyobj.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\include\amosmodule.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\..\..\bin\amos2.lib
# End Source File
# End Target
# End Project
