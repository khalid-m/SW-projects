# Microsoft Developer Studio Project File - Name="pyamos" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=pyamos - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "pyamos.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "pyamos.mak" CFG="pyamos - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "pyamos - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "pyamos - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "pyamos - Win32 Release With Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "pyamos - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x41d /d "NDEBUG"
# ADD RSC /l 0x41d /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /out:"../../../../bin/python_ext.dll" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\embeddings\Python\libs"

!ELSEIF  "$(CFG)" == "pyamos - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x41d /d "_DEBUG"
# ADD RSC /l 0x41d /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\embeddings\Python\libs"

!ELSEIF  "$(CFG)" == "pyamos - Win32 Release With Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "pyamos___Win32_Release_With_Debug"
# PROP BASE Intermediate_Dir "pyamos___Win32_Release_With_Debug"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "pyamos___Win32_Release_With_Debug"
# PROP Intermediate_Dir "pyamos___Win32_Release_With_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /ZI /Od /I "$(PYTHON_HOME)\Include" /I "$(PYTHON_HOME)\Lib\site-packages\numpy\core\include\numpy" /I "$(AMOS_HOME)\C" /I "$(AMOS_HOME)\system\include" /I "$(AMOS_HOME)\embeddings\Python\include" /D "WIN32" /D "DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "PYAMOS_EXPORTS" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x41d /d "NDEBUG"
# ADD RSC /l 0x41d /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386 /out:"../../../../bin/python_ext.dll" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\embeddings\Python\libs"
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /incremental:yes /debug /machine:I386 /out:"../../../../bin/python_ext.dll" /libpath:"$(PYTHON_HOME)\libs" /libpath:"$(AMOS_HOME)\embeddings\Python\libs"

!ENDIF 

# Begin Target

# Name "pyamos - Win32 Release"
# Name "pyamos - Win32 Debug"
# Name "pyamos - Win32 Release With Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\..\C\amosmodule.c
# End Source File
# Begin Source File

SOURCE=..\..\C\pyamos_init.c
# End Source File
# Begin Source File

SOURCE=..\..\C\pycallout.c
# End Source File
# Begin Source File

SOURCE=..\..\C\pymodule.c
# End Source File
# Begin Source File

SOURCE=..\..\C\pyobj.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\include\amosmodule.h
# End Source File
# Begin Source File

SOURCE=..\..\include\pycallout.h
# End Source File
# Begin Source File

SOURCE=..\..\include\pymodule.h
# End Source File
# Begin Source File

SOURCE=..\..\include\pyobj.h
# End Source File
# Begin Source File

SOURCE=..\..\include\record.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=..\..\..\..\bin\amos2.lib
# End Source File
# End Target
# End Project
